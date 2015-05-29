module Egauge
  attr_reader :registers

  class History
    def initialize(db, client: nil, register_names: nil)
      @client = client || Client.new
      @register_names = register_names
      @registers = nil
      @db = db
    end

    def epoch
      response = @client.request_history(units: REQ_UNIT_DAYS)
      Time.at(response.body['group']['data']['epoch'].to_i(16))
    end

    def load(time_from:, time_until: nil, units: REQ_UNIT_HOURS)
      response = @client.request_history(time_from: time_from,
                                         time_until: time_until,
                                         units: units)
      @registers = load_into_registers(response.body, units: units)
      @registers
    end

    # load the time of the last synced 
    def last_sync_time
      query = 'select max(time) as last_sync_time from  series'
      result = DB[query].first
      result[:last_sync_time] unless result.nil?
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
      if data.is_a? Array
        LOGGER.error "body['group']['data'] is an Array.  Don't know how to cope yet"
        data = data.first
      end
      registers = data['cname'].map { |x| x['__content__'] }
      request_time = Time.at(data['time_stamp'].to_i(16))

      #delta_time = time_units_in_secs(units)
      delta_time = data['time_delta'].to_i

      registers.each_with_index do |register_name,i|
        if !@register_names.nil?
          next unless @register_names.include?(register_name)
        end
        if data['r'].nil?
          LOGGER.warn 'No metrics for this time period'
          next
        end
        data['r'].each_with_index do |row,time_idx|
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
