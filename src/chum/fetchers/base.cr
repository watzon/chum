module Chum
  module Fetchers
    abstract struct Base
      Log = ::Log.for(self)

      def initialize(@spider : Spider)
      end

      abstract def fetch(request : Request) : Response
      abstract def url(request : Request) : Request
    end
  end
end
