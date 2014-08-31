module Egauge
  class Client
    def initialize
      fail 'Egauge.configuration.url not specified' if Egauge.configuration.url.nil?

      @conn = Faraday.new(url: Egauge.configuration.url) do |faraday|
        faraday.response :csv, headers: true
        faraday.adapter  Faraday.default_adapter
        faraday.options.params_encoder = Faraday::FlatParamsEncoder
      end
    end

    def request_history(time_from: nil, time_until: nil, units: REQ_UNIT_HOURS)
      @conn.get do |req|
        req.url '/cgi-bin/egauge-show'
        req.params = [REQ_CSV, units, REQ_EXTRA_POINT]
        req.params[REQ_TIMESTAMP_FROM] = time_from.to_date.to_time.to_i
      end
    end
  end
end
