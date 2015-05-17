require 'digest/sha1'

module Egauge
  class Register
    attr_reader :name, :normalized_name

    def initialize(name:)
      @name = name
      @normalized_name = normalize_name
      @values = []
    end

    def add_value(time:, joules:)
      @values << { time: time, joules: joules, wh: joules / JOULES_PER_WH }
    end

    # write the register to influxdb
    def write(influxdb)
      @values.each do |data|
        influxdb_data = data.clone
        influxdb_data[:time] = influxdb_data[:time].to_i
        influxdb.write_point(@normalized_name, influxdb_data)
      end
    end

    def values(by: :hour)
      result = case by
      when :hour
        @values
      when :day
        last_points_in_day(@values)
      else
        fail 'invalid by'
      end
      result = deltas(result)
      result[1..-1]
    end

    # normalize the register name and turn it into a symbol with 
    # underscores plus a shortened sha1 hash
    # this can cause name collisions, in theory
    # "Date & Time" => 'date_time_a9993e36470'
    # "Register 1 [kWh]" => 'register_1_kwh_a9993e36470'
    def normalize_name
      lower = @name.downcase
      non_word = lower.gsub(/\W/,'_').gsub(/_+/,'_')
      normalized = non_word.split('_').compact.join('_')
      [normalized, Digest::SHA1.hexdigest(@name)[0..10]].join('_')
    end

    # for each day, get the last data point
    def last_points_in_day(values)
      values = values.sort { |a,b| a[:time] <=> b[:time] }
      values = values.group_by { |data| data[:time].to_date }
      values.map { |date,data| data.last }
    end

    def deltas(values)
      values = values.sort { |a,b| a[:time] <=> b[:time] }
      values.each_with_index do |data,i|
        values[i][:delta] = data[:value] - values[i-1][:value]
      end
      values
    end

  end
end
