module Chum
  class Engine
    Log = ::Log.for(self)

    property started_spiders : Synchronized(Array(Spider)) = Synchronized(Array(Spider)).new
    property request_storage : RequestStorage = RequestStorage.new

    property channel : Channel(Nil) = Channel(Nil).new

    def start_spider(spider : Spider) : Void
      @started_spiders.push(spider)

      spider.start_urls.each do |url|
        @request_storage.store(spider, url)
      end

      spawn do
        until @request_storage.empty?(spider)
          request = @request_storage.pop!(spider)

          begin
            if !spider.renderer.fall_through
              request = spider.fetcher.url(request)
              response = spider.renderer.render(request)

              parsed_item = spider.parse_item(request, response)

              parse(spider, parsed_item)
            else
              response = spider.fetcher.fetch(request)
              parsed_item = spider.parse_item(request, response)

              parse(spider, parsed_item)
            end
          rescue exception : Crest::RequestFailed
            status_code = exception.response.status_code.to_i

            case status_code
            when 404, 405, 500..511
              Log.error(exception: exception) { "Dropping the request, failed to get a response status code which could be used to recover a request." }
            else
              Log.info { exception.message }

              if request.is_retriable?
                request.retry
                @request_storage.store(spider, request)
              end
            end
          rescue exception : Exception
            Log.error(exception: exception) { "Dropping the request, a non HTTP error occured." }
          end

          if @request_storage.empty?(spider)
            spider.cache.flush
            @started_spiders.delete(spider)
          end

          if @started_spiders.empty?
            @channel.send(nil)
          end
        end
      end
    end

    def wait
      @channel.receive
    end

    def stop_spider(spider : Spider) : Void
      spider.cache.flush
      @request_storage.flush(spider)
      @started_spiders.delete(spider)
    end

    private def parse(spider : Spider, parsed_item : ParsedItem) : Void
      unless parsed_item.requests.empty?
        parse_requests(spider, parsed_item)
      end

      unless parsed_item.items.empty?
        parse_items(spider, parsed_item)
      end
    end

    private def parse_requests(spider : Spider, parsed_item : ParsedItem) : Void
      @request_storage.store(spider, parsed_item.requests)
    end

    private def parse_items(spider : Spider, parsed_item : ParsedItem) : Void
      response = parsed_item.items.first.dig(:response)

      if response.pipethrough?(spider)
        spider.parser.parse(response)
      end
    end
  end
end
