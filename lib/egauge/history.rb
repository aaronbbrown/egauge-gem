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
      response.body
      @registers = load_into_registers(response.body, units: units)
    end

    def register_names
      @registers.map { |x| x.name }
    end

    def register(name)
      if @registers.nil?
        fail 'registers not populated, call #load_daily'
      end
      index = @registers.find_index { |x| x.name == name }
      if index.nil?
        fail 'no such register'
      end
      @registers[index]
    end


    # given some units, normalize to seconds
    # e.g. REQ_UNIT_HOURS returns 3600
    def time_units_in_secs(units)
      case units
      when REQ_UNIT_DAYS then 86_400
      when REQ_UNIT_HOURS then 3600
      when REQ_UNIT_MINS then 60
      when REQ_UNIT_SECS then 1
      end
    end

    def load_into_registers(body, units:)
      result = []
      data = body['group']['data']
      registers = data['cname'].map { |x| x['__content__'] }
      request_time = Time.at(data['time_stamp'].to_i(16))
      delta_time = time_units_in_secs(units)

      registers.each_with_index do |register_name,i|
        prev_value = 0
        body['group']['data']['r'].each_with_index do |row,time_idx|
          result[i] ||= Register.new(name: register_name)
          delta_value = prev_value - row['c'][i].to_i
          # value out of eGauge (t="P") is in Joules.  Convert to Wh
          result[i].add_value(value: delta_value.to_f / JOULES_PER_WH ,
                              time: request_time - delta_time * time_idx)
          prev_value = row['c'][i].to_i
        end
      end
      result
    end

    # normalize the header and turn it into a symbol with underscores
    # this can cause name collisions, for example Solar and Solar+
    # "Date & Time" => :date_time
    # "Register 1 [kWh]" => :register_1_kwh
    def normalize_header(header_value)
      lower = header_value.downcase
      non_word = lower.gsub(/\W/,'_').gsub(/_+/,'_')
      non_word.split('_').compact.join('_').to_sym
    end

    # "use [kWh]", => use
    # "gen [kWh]", => gen
    # "Solar [kWh]", => Solar
    # "Solar+ [kWh]", => Solar+
    # "Register 1 [kWh]", => Register 1
    # "Register 2 [kWh]"], => Register 2
    def register_name(header_value)
      header_value.split(' ')[0..-2].join(' ')
    end

    # parsed_csv_to_hash converts the csv format to
    # this Hash representation
    #
    # {:registers=>
    #   {:use_kwh=>{:value=>0.0, :name=>"use"},
    #    :gen_kwh=>{:value=>3270.129630833, :name=>"gen"},
    #    :solar_kwh=>{:value=>3435.785158333, :name=>"Solar+"},
    #    :register_1_kwh=>{:value=>1263.874641667, :name=>"Register 1"},
    #    :register_2_kwh=>{:value=>1251.416052222, :name=>"Register 2"}},
    #  :date_time=>2014-07-31 23:45:00 -0400},
    def to_hash(body)
      registers = body['group']['data']['cname'].map { |x| x['__content__'] }
      body[1..-1].map do |row|
        new_row = { registers: {} }
        headers.each_with_index do |header,i|
          value = infer_type(row[i])
          normalized_header = normalize_header header
          if normalized_header == :date_time
            value = Time.at(value)
            new_row[normalized_header] = value
          else
            new_row[:registers][header] ||= {}
            new_row[:registers][header][:value] = value
            new_row[:registers][header][:name] = register_name(header)
          end
        end
        new_row
      end.sort { |a,b| a[:date_time] <=> b[:date_time] }
    end

    # try to figure out if the string is a float, integer, or something
    # else and convert
    def infer_type(value)
      case value
      when /^-?\d+\.\d+$/ # -123.456
        value.to_f
      when /^-?\d+$/      # -123
        value.to_i
      else                # stuff
        value
      end
    end

  end
end
