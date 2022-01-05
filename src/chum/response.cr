module Chum
  class Response < Crest::Response
    Log = ::Log.for(self)

    def pipethrough?(spider : Spider) : Response?
      results = spider.pipelines.map do |pipeline|
        pipeline.run(self, spider)
      end

      unless results.all?
        nil
      end

      self
    end
  end
end
