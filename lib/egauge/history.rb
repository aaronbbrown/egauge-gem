module Egauge
  attr_reader :registers

  class History
    def initialize(client = nil)
      @client = client || Client.new
      @registers = nil
    end

    def load(time_from:, time_until: nil, units: REQ_UNIT_HOURS)
      response = @client.request_history(time_from: time_from,
                                         time_until: time_until,
                                         units: units)
#      binding.pry
      @registers = load_into_registers(response.body, units: units)
      @registers
    end

    # given some units, normalize to seconds
    # e.g. REQ_UNIT_HOURS returns 3600
    def time_units_in_secs(units)
      case units
      when REQ_UNIT_DAYS then 86_400
      when REQ_UNIT_HOURS then 3600
      when REQ_UNIT_MINUTES then 60
      end
    end

    def load_into_registers(body, units:)
      result = []
      data = body['group']['data']
      registers = data['cname'].map { |x| x['__content__'] }
      request_time = Time.at(data['time_stamp'].to_i(16))
      delta_time = time_units_in_secs(units)

      registers.each_with_index do |register_name,i|
        body['group']['data']['r'].each_with_index do |row,time_idx|
          next if time_idx == 0
          result[i] ||= Register.new(name: register_name)
          t = request_time - delta_time * time_idx
          result[i].add_value(joules: row['c'][i].to_i, time: t)
        end
      end
      result
    end
  end
end
