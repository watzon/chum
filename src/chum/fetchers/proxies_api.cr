module Chum
  module Fetchers
    struct ProxiesApi < Base
      Log = ::Log.for(self)

      def initialize(@spider : Spider, @api_key : String)
      end

      def fetch(request : Request) : Response
        if request.pipethrough?(@spider)
          url = "http://api.proxiesapi.com/?auth_key=#{@api_key}&url=#{request.url}"
          request = Request.new(:get, url)

          Response.new(request.execute.http_client_res, request)
        else
          Log.error { "Failed to validate the request to #{request.url} through the pipeline for spider #{@spider.id}." }
          raise Exception.new
        end
      end

      def url(request : Request) : Request
        Request.new(:get, "http://api.proxiesapi.com/?auth_key=#{@api_key}&url=#{request.url}")
      end
    end
  end
end
