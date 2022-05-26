module Chum
  module Renderers
    struct Chrome < Base
      @@instance = new

      def self.instance
        @@instance
      end

      property session : Marionette::Session = Marionette::WebDriver.create_session(:chrome, capabilities: Marionette.chrome_options(args: ["headless"]))

      def fall_through : Bool
        false
      end

      def render(request : Request) : Response
        @session.navigate(request.url)
        response = HTTP::Client::Response.new(status: HTTP::Status::OK, body: @session.page_source)
        Response.new(response, request)
      end
    end
  end
end
