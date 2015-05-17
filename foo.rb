#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pp'
require 'csv'
require 'time'
require 'egauge'
require 'json'

Egauge.configure do |config|
  config.url = 'http://sol.borg.lan'
end

history = Egauge::History.new
h = history.load(time_from: (Time.new-86_400*30), units: Egauge::REQ_UNIT_MINUTES)
pp h



#register = history.register 'gen'
#pp register.values by: :day

