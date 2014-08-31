require 'faraday'
require 'egauge/version'
require 'egauge/configuration'

# Faraday::Response.register_middleware eguage_history: -> lambda { Egauge::Middleware::History }

require 'faraday_middleware'
require 'faraday_csv'
require 'json'

Faraday::Response.register_middleware csv: lambda { Faraday::Response::CSV }

require 'egauge/constants'
require 'egauge/register'
require 'egauge/client'
require 'egauge/history'

