module Chum
  module Renderers
    struct Default < Base
      def fall_through : Bool
        true
      end

      def render(request : Request) : Response
        response = HTTP::Client::Response.new(status: HTTP::Status::IM_A_TEAPOT)
        Response.new(response, request)
      end
    end
  end
end
