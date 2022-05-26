module HumanResources
  struct Parser
    include Chum::Parser

    def parse(response : Crest::Response) : Void
      document = Lexbor::Parser.new(response.body)

      id = document.find("h4.text-center").first.inner_text.strip.split(" ").last

      puts "ID: #{id}"
    end
  end
end
