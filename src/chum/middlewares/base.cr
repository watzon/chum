module Chum
  module Middlewares
    abstract struct Base
      Log = ::Log.for(self)

      abstract def run(request : Request, spider : Spider) : Bool
    end
  end
end
