#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pp'
require 'csv'
require 'time'
require 'date'
require 'egauge'
require 'json'
require 'influxdb'
require 'logger'
require 'pry'

START_DATE = Time.mktime(2015,1,1).to_date
DATABASE = 'solar'
LOGGER = Logger.new($stderr)
LOGGER.level = Logger::DEBUG

Egauge.configure do |config|
  config.url = 'http://sol.borg.lan'
end

influxdb = InfluxDB::Client.new(DATABASE, hosts: ['127.0.0.1'])
InfluxDB::Logging.logger = LOGGER
databases = influxdb.get_database_list
if databases.map { |x| x['name'] }.include? DATABASE
  influxdb.delete_database(DATABASE)
  influxdb.create_database(DATABASE)
end

START_DATE.upto(Date.today + 1) do |date|
  start_t = date.to_time
  # assumes second granularity
  end_t = (date + 1).to_time - 1
  LOGGER.info "Loading from #{start_t} until #{end_t}"

  history = Egauge::History.new
  h = history.load(time_from: start_t, time_until: end_t,
                  units: Egauge::REQ_UNIT_MINUTES)

  h.each do |register|
    register.write(influxdb)
  end
end

#register = history.register 'gen'
#pp register.values by: :day

