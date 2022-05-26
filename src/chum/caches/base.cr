module Chum
  module Caches
    abstract struct Base
      Log = ::Log.for(self)

      property id : String

      def initialize(@id : String)
      end

      abstract def save!(url) : Void
      abstract def delete!(url) : Void
      abstract def list! : Array(String)
      abstract def list_requests!(base_url) : Array(Request)
      abstract def flush : Void
    end
  end
end
