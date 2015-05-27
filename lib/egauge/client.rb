module Egauge
  class Client
    def initialize
      fail 'Egauge.configuration.url not specified' if Egauge.configuration.url.nil?

      @conn = Faraday.new(url: Egauge.configuration.url) do |faraday|
        faraday.response :xml, headers: true
        faraday.adapter  Faraday.default_adapter
        faraday.options.params_encoder = Faraday::FlatParamsEncoder
      end
    end

    def request_history(time_from: nil, time_until: nil, units: REQ_UNIT_HOURS)
      @conn.get do |req|
        req.url '/cgi-bin/egauge-show'
        req.params = [units, REQ_VIRTUAL, REQ_DELTA]
        if time_from
          req.params[REQ_TIMESTAMP_FROM] = time_from.to_i
        end
        if time_until
          req.params[REQ_TIMESTAMP_UNTIL] = time_until.to_i
        end
      end
    end
  end
end
