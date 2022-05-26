module Chum
  module Renderers
    abstract struct Base
      abstract def fall_through : Bool
      abstract def render(request : Request) : Response
    end
  end
end
