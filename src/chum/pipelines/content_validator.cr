module Chum
  module Pipelines
    struct ContentValidator < Base
      Log = ::Log.for(self)

      def initialize(@selector : String)
      end

      def run(response : Response, _spider : Spider) : Bool
        document = Lexbor::Parser.new(response.body)

        document.find(@selector).any?
      end
    end
  end
end
