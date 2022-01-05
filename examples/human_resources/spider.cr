module HumanResources
  class Spider
    include Chum::Spider

    def id : String
      "hr-gov-ge"
    end

    def base_url : String
      "https://www.hr.gov.ge/"
    end

    def cache : Chum::Caches::Base
      Chum::Caches::Redis.new(self)
    end

    def start_urls : Array(String)
      [
        "https://www.hr.gov.ge/?pageNo=1",
      ]
    end

    def start_requests : Array(Chum::Request)
      cache.list_requests!(base_url())
    end

    def parser : Chum::Parser
      Parser.new
    end

    # Executed on the request class
    def middlewares : Array(Chum::Middlewares::Base)
      [
        Chum::Middlewares::DomainFilter.new,
        Chum::Middlewares::UserAgent.new,
      ]
    end

    # Executed on the response class
    def pipelines : Array(Chum::Pipelines::Base)
      [
        Chum::Pipelines::ContentValidator.new(selector: ".logo"),
      ] of Chum::Pipelines::Base
    end

    def fetcher : Chum::Fetchers::Base
      Chum::Fetchers::Stock.new(self)
    end

    # def fetcher : Chum::Fetchers::Base
    #   Chum::Fetchers::ScrapeAPi.new(self, api_key: "fbz870e31az5e8ff392812928dd712i3k")
    # end

    # def fetcher : Chum::Fetchers::Base
    #   Chum::Fetchers::ProxiesApi.new(self, api_key: "fbz870e31az5e8ff392812928dd712i3k_jkoq_sqqmz1")
    # end

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

    def listing_urls(document : Lexbor::Parser) : Array(String)
      document
        .find(".table.vacans-table.additional-documents a")
        .map { |a| a.attribute_by("href").to_s }
        .uniq
        .map { |href| Chum::Utils.build_absolute_url(href, base_url) }
    end

    def pagination_urls(document : Lexbor::Parser) : Array(String)
      document
        .find("li.PagedList-skipToNext a")
        .map { |a| a.attribute_by("href").to_s }
        .uniq
        .map { |href| Chum::Utils.build_absolute_url(href, base_url) }
    end
  end
end
