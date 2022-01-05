module Chum
  module Pipelines
    abstract struct Base
      Log = ::Log.for(self)

      abstract def run(response : Response, spider : Spider) : Bool
    end
  end
end
