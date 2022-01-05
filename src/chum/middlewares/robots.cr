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
        @parser.allowed?(path)
      end
    end
  end
end
