module Chum
  module Fetchers
    struct Stock < Base
      Log = ::Log.for(self)

      def initialize(@spider : Spider)
      end

      def fetch(request : Request) : Response
        if request.pipethrough?(@spider)
          Response.new(request.execute.http_client_res, request)
        else
          Log.error { "Failed to validate the request to #{request.url} through the pipeline for spider #{@spider.id}." }
          raise Exception.new
        end
      end
    end
  end
end
