module HumanResources
  struct Parser
    include Chum::Parser

    private property keywords : Hash(String, String) = {
      "თანამდებობის_დასახელება"       => "positionTitle",
      "პოზიციის_დასახელება"           => "nameOfThePosition",
      "კონკურსის_ტიპი"                => "typeOfCompetition",
      "ორგანიზაცია"                   => "organizationName",
      "ორგანიზაციის_შესახებ"          => "aboutOrganization",
      "კატეგორია"                     => "category",
      "განცხადების_ბოლო_ვადა"         => "applicationDeadline",
      "თანამდებობრივი_სარგო"          => "salaryOfThePosition",
      "ადგილების_რაოდენობა"           => "numberOfPositions",
      "სამსახურის_ადგილმდებარეობა"    => "officeLocation",
      "სამუშაოს_ტიპი"                 => "workType",
      "გამოსაცდელი_ვადა"              => "probationaryPeriod",
      "მოთხოვნები"                    => "requirements",
      "მინიმალური_განათლება"          => "requiredMinimumOfEducation",
      "სამუშაო_გამოცდილება"           => "workExperience",
      "პროფესია"                      => "profession",
      "საკონტაქტო_ინფორმაცია"         => "contactInformation",
      "საკონკურსო_კომისიის_მისამართი" => "addressOfTheCompetitionCommission",
      "საკონტაქტო_ტელეფონები"         => "contactTelephone",
      "საკონტაქტო_პირი"               => "contactPerson",
    }

    def parse(response : Crest::Response) : Void
      document = Lexbor::Parser.new(response.body)

      _id = document.find("h4.text-center").first.inner_text.strip.split(" ").last
      keys = document.find("dl.dl-horizontal dt").map(&.inner_text.strip)
      values = document.find("dl.dl-horizontal dd").map(&.inner_text.strip)

      table = Hash.zip(keys, values)

      pairs = table.map do |key, value|
        substitute_key = keywords[key.strip.gsub(" ", "_").gsub(":", "")]

        table.delete(key)
        {substitute_key => value}
      end

      pairs.each do |pair|
        table.merge!(pair)
      end
    end
  end
end
