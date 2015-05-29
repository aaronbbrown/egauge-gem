#!/usr/bin/env ruby

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pp'
require 'csv'
require 'time'
require 'date'
require_relative '../lib/egauge'
require 'json'
require 'sequel'
require 'logger'
require 'pry'

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

migration_path = File.expand_path('../../db/migrate', __FILE__)
Sequel::Migrator.run(DB, migration_path)

now = Time.new
today = now.to_date
history = Egauge::History.new(DB, register_names: %w(use gen))
epoch = history.epoch
last_sync_time = history.last_sync_time
start_date = last_sync_time.nil? ? epoch.to_date : last_sync_time.to_date

if start_date == today
  LOGGER.info "Last synced at #{last_sync_time}. Pulling new metrics until #{now}..."
  # don't bother batching for less than a day
  h = history.load(time_from: last_sync_time+1, time_until: now, units: Egauge::REQ_UNIT_MINUTES)
  h.each { |register| register.write(DB) }
else
  start_date.upto(Date.today) do |date|
    start_t = date.to_time
    # assumes second granularity
    end_t = [(Time.new-60), ((date + 1).to_time)].min
    LOGGER.info "Loading from #{start_t} until #{end_t}"

    history = Egauge::History.new(DB)
    h = history.load(time_from: start_t, time_until: end_t,
                    units: Egauge::REQ_UNIT_MINUTES)

    h.each { |register| register.write(DB) }
  end
end
