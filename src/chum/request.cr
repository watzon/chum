module Chum
  class Request < Crest::Request
    Log = ::Log.for(self)

    private property retry_count : Int32 = 0

    def pipethrough?(spider : Spider) : Request?
      results = spider.middlewares.map do |middleware|
        middleware.run(self, spider)
      end

      unless results.all?
        return nil
      end

      self
    end

    def set_proxy!(p_addr, p_port, p_user, p_pass)
      return unless p_addr && p_port

      @proxy = HTTP::Proxy::Client.new(p_addr, p_port, username: p_user, password: p_pass)
    end

    def is_retriable? : Bool
      @retry_count <= 5
    end

    def retry : Void
      @retry_count += 1
    end
  end
end
