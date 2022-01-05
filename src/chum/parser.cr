module Chum
  module Parser
    Log = ::Log.for(self)

    abstract def parse(response : Response)
  end
end
