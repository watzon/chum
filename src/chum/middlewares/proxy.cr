module Chum
  module Middlewares
    struct Proxy < Base
      Log = ::Log.for(self)

      def initialize(@address : String, @port : Int32, @username : String, @password : String)
      end

      def run(request : Request, spider : Spider) : Bool
        request.set_proxy!(@address, @port, @username, @password)

        request.proxy != nil
      end
    end
  end
end
