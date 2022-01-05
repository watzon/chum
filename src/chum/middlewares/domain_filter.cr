module Chum
  module Middlewares
    struct DomainFilter < Base
      Log = ::Log.for(self)

      def run(request : Request, spider : Spider) : Bool
        base_url = spider.base_url
        parsed_url = URI.parse(request.url)
        host = parsed_url.host

        valid = base_url.includes?(host.not_nil!)

        unless valid
          Log.debug { "Dropping request: #{request.url} (domain filter)" }
          return false
        end

        true
      end
    end
  end
end
