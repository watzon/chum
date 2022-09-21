module HumanResources
  class Spider
    include Chum::Spider

    # Class variable for the identificator.
    @@id = "hr-gov-ge"

    # Identificator of the spider throughout the whole system.
    property id : String = @@id

    # The base URL of the website.
    property base_url : String = "https://www.hr.gov.ge/"

    # Start URL's for the spider.
    property start_urls : Array(String) = ["https://www.hr.gov.ge/?pageNo=1"]

    # Caching mechanism used by the spider to cache the requests in case of a restart/failure.
    property cache : Chum::Caches::Base = Chum::Caches::Redis.new(@@id)

    # Parser used by the spider to parse the HTML content.
    property parser : Chum::Parser = Parser.new

    # Middlewares used by the spider to filter the requests.
    property middlewares : Array(Chum::Middlewares::Base) = [Chum::Middlewares::DomainFilter.new, Chum::Middlewares::UserAgent.new]

    # Pipelines used by the spider to filter the responses.
    property pipelines : Array(Chum::Pipelines::Base) = [Chum::Pipelines::ContentValidator.new(selector: ".Title-box")] of Chum::Pipelines::Base

    #
    # Rendering client which can be used by the spider to render the content without the fetchers.
    #
    # If you want to use the Chrome renderer add the chromedriver to your PATH
    # and change this line to:
    # property renderer : Chum::Renderers::Base = Chum::Renderers::Chrome.new
    #
    property renderer : Chum::Renderers::Base = Chum::Renderers::Default.new

    # Used by the caching mechanism to retrieve the requests from the cache.
    def start_requests : Array(Chum::Request)
      cache.list_requests!(base_url())
    end

    # Fetcher used by the spider to request the URL's.
    def fetcher : Chum::Fetchers::Base
      Chum::Fetchers::Default.new(self)
    end

    # Parsing logic to identify the listing URL's from pagination URL's
    def parse_item(request : Chum::Request, response : Chum::Response) : Chum::ParsedItem
      cache.delete!(request.url)

      if request.url.includes?("https://www.hr.gov.ge/?pageNo=")
        document = Lexbor::Parser.new(response.body)

        listing_urls = listing_urls(document)
        pagination_urls = pagination_urls(document)

        urls = listing_urls + pagination_urls
        cache.save!(urls)

        requests = urls.map do |url|
          Chum::Request.new(:get, url)
        end

        Chum::ParsedItem.new(requests: requests, items: [] of NamedTuple(response: Chum::Response))
      else
        item = {response: response}
        Chum::ParsedItem.new(requests: [] of Chum::Request, items: [item])
      end
    end

    # Parse HTML for listing URL's.
    def listing_urls(document : Lexbor::Parser) : Array(String)
      document
        .find(".table.vacans-table.additional-documents a")
        .map { |a| a.attribute_by("href").to_s }
        .uniq
        .map { |href| Chum::Utils.build_absolute_url(href, base_url) }
    end

    # Parse HTML for pagination URL's
    def pagination_urls(document : Lexbor::Parser) : Array(String)
      document
        .find("li.PagedList-skipToNext a")
        .map { |a| a.attribute_by("href").to_s }
        .uniq
        .map { |href| Chum::Utils.build_absolute_url(href, base_url) }
    end
  end
end
