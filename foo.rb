#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

START_TIME = Time.new-86_400*7
DATABASE = 'solar'

require 'pp'
require 'csv'
require 'time'
require 'egauge'
require 'json'
require 'influxdb'
require 'logger'

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

history = Egauge::History.new
h = history.load(time_from: START_TIME,
                 units: Egauge::REQ_UNIT_MINUTES)


h.each do |register|
  register.write(influxdb)
end


#register = history.register 'gen'
#pp register.values by: :day

