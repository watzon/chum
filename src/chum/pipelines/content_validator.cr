module Chum
  module Pipelines
    struct ContentValidator < Base
      Log = ::Log.for(self)

      def initialize(@selector : String)
      end

      def run(response : Response, spider : Spider) : Bool
        document = Lexbor::Parser.new(response.body)
        valid = document.find(@selector).size != 0

        unless valid
          Log.error { "Page failed validation: #{response.url}" }
          return false
        end

        true
      end
    end
  end
end
