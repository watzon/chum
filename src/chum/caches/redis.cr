module Chum
  module Caches
    struct Redis < Base
      Log = ::Log.for(self)

      property spider : Spider

      def initialize(@spider : Spider)
        @client = ::Redis.new
      end

      def save!(url) : Void
        @client.sadd(key, url)
      end

      def delete!(url) : Void
        @client.srem(key, url)
      end

      def list! : Array(String)
        @client.smembers(key)
      end

      def list_requests!(base_url) : Array(Request)
        urls = Utils.build_absolute_urls(@client.smembers(key), base_url)
        Utils.requests_from_urls(urls)
      end

      def flush : Void
        @client.del(key)
      end

      private def key : String
        %(#{@spider.id}:urls-cache)
      end
    end
  end
end
