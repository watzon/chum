module Chum
  class RequestStorage
    Log = ::Log.for(self)

    private property requests : Synchronized(Hash(String, Array(Request))) = Synchronized(Hash(String, Array(Request))).new
    private property history : Synchronized(Hash(String, Array(String))) = Synchronized(Hash(String, Array(String))).new

    def store(spider : Spider, request : Request) : Void
      if @requests.has_key?(spider.id)
        unless @history[spider.id].includes?(request.url)
          @history[spider.id].push(request.url)
          @requests[spider.id].push(request)
        end
      else
        @history[spider.id] = [request.url]
        @requests[spider.id] = [request]
      end
    end

    def store(spider : Spider, requests : Array(Request)) : Void
      requests.each do |request|
        store(spider, request)
      end
    end

    def store(spider : Spider, url : String) : Void
      store(spider, Request.new(:get, url))
    end

    def store(spider : Spider, urls : Array(String)) : Void
      urls.each do |url|
        store(spider, url)
      end
    end

    def pop!(spider : Spider) : Request
      @requests[spider.id].pop
    end

    def pop?(spider : Spider) : Request?
      @requests[spider.id].pop?
    end

    def flush(spider : Spider) : Void
      @requests[spider.id] = [] of Request
    end

    def empty?(spider : Spider) : Bool
      @requests[spider.id].empty?
    end
  end
end
