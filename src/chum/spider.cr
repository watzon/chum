module Chum
  module Spider
    Log = ::Log.for(self)

    abstract def id : String
    abstract def base_url : String
    abstract def cache : Caches::Base
    abstract def start_urls : Array(String)
    abstract def start_requests : Array(Request)
    abstract def parser : Parser
    abstract def parse_item(request : Request, response : Response) : ParsedItem
    abstract def middlewares : Array(Middlewares::Base)
    abstract def pipelines : Array(Pipelines::Base)
    abstract def fetcher : Fetchers::Base
    abstract def renderer : Renderers::Base
  end
end
