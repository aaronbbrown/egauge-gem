# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'egauge/version'

Gem::Specification.new do |spec|
  spec.name          = "egauge"
  spec.version       = Egauge::VERSION
  spec.authors       = ["Aaron Brown"]
  spec.email         = ["aaron@9minutesnooze.com"]
  spec.summary       = %q{Library to work wtih EGauge}
  spec.description   = %q{Library to work wtih EGauge}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop"
  %w{pry pry-rescue pry-stack_explorer}.each do |gem|
    spec.add_development_dependency gem
  end
  spec.add_dependency 'sequel'
  spec.add_dependency 'pg'
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
#  spec.add_dependency "faraday_csv"
  spec.add_dependency 'multi_xml'
end
