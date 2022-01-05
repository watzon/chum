module Chum
  module Middlewares
    struct Robots < Base
      Log = ::Log.for(self)

      getter parser : ::Robots::Parser

      def initialize(@base_url : String, @user_agent : String)
        @parser = ::Robots::Parser.new(@base_url, @user_agent)
      end

      def run(request : Request, spider : Spider) : Bool
        path = URI.parse(request.url).path
        valid = @parser.allowed?(path)

        unless valid
          Log.debug { "Dropping request: #{request.url} (robots.txt filter)" }
          return false
        end

        true
      end
    end
  end
end
