module Chum
  module Middlewares
    struct DomainFilter < Base
      Log = ::Log.for(self)

      def run(request : Request, spider : Spider) : Bool
        base_url = spider.base_url
        parsed_url = URI.parse(request.url)
        host = parsed_url.host

        base_url.includes?(host.not_nil!)
      end
    end
  end
end
