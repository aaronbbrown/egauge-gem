#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

START_TIME = Time.new-86_400*7
DATABASE = 'electrical'

require 'pp'
require 'csv'
require 'time'
require 'egauge'
require 'json'
require 'elasticsearch'
require 'logger'

LOGGER = Logger.new($stderr)
LOGGER.level = Logger::DEBUG

Egauge.configure do |config|
  config.url = 'http://sol.borg.lan'
end

client = Elasticsearch::Client.new log: true
client.index index: DATABASE, type: 'foo', body: {}



history = Egauge::History.new
h = history.load(time_from: START_TIME,
                 units: Egauge::REQ_UNIT_MINUTES)


h.each do |register|
  register.write(client, DATABASE)
end


#register = history.register 'gen'
#pp register.values by: :day

