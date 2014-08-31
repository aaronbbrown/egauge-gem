module Egauge
  class Register
    attr_reader :name

    def initialize(name:)
      @name = name
      @values = []
    end

    def add_value(time:, value:)
      @values << { time: time, value: value }
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
