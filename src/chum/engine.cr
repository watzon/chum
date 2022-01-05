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
          response = spider.fetcher.fetch(request)

          if response.pipethrough?(spider)
            if response.status_code == 200
              parsed_item = spider.parse_item(request, response)

              unless parsed_item.requests.empty?
                @request_storage.store(spider, parsed_item.requests)
              end

              unless parsed_item.items.empty?
                spider.parser.parse(parsed_item.items.first.dig(:response))
              end
            else
              Log.error { "The status code of the response was #{response.status_code}, the request will be rescheduled." }

              if request.is_retriable?
                request.retry
                @request_storage.store(spider, request)
              else
                Log.debug { "The request was recheduled more than 5 times, dropping the request." }
              end
            end
          else
            Log.error { "The response failed to pass the pipeline, #{response.url}" }
          end
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

    def wait
      @channel.receive
    end

    def stop_spider(spider : Spider) : Void
      spider.cache.flush
      @request_storage.flush(spider)
      @started_spiders.delete(spider)
    end
  end
end
