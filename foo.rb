#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pp'
require 'csv'
require 'time'
require 'date'
require 'egauge'
require 'json'
require 'sequel'
require 'logger'
require 'pry'

START_DATE = Time.mktime(2015,1,1).to_date
#START_DATE = Time.mktime(2015,5,22).to_date
DATABASE = 'solar'
LOGGER = Logger.new($stderr)
LOGGER.level = Logger::INFO

Egauge.configure do |config|
  config.url = 'http://sol.borg.lan'
end

Sequel.extension :migration

DB = Sequel.connect(adapter: 'postgres', database: DATABASE,
                    user: 'aaron',
                    logger: LOGGER, sql_log_level: :debug)

Sequel::Migrator.run(DB, 'db/migrate')

START_DATE.upto(Date.today) do |date|
  start_t = date.to_time
  # assumes second granularity
  end_t = [(Time.new-60), ((date + 1).to_time - 1)].min
  LOGGER.info "Loading from #{start_t} until #{end_t}"

  history = Egauge::History.new
  h = history.load(time_from: start_t, time_until: end_t,
                   units: Egauge::REQ_UNIT_MINUTES)

  h.each do |register|
    register.write(DB)
  end
end

#register = history.register 'gen'
#pp register.values by: :day

