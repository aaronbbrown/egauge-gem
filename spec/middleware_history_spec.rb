require_relative 'spec_helper'

describe Egauge::Middleware::History do
  before do
    @faraday = Faraday.new do |builder|
      builder.use Egauge::Middleware::History
      builder.adapter :test do |stub|
        stub.get('/ebi') {[ 200, {}, 'shrimp' ]}
      end
    end
  end

  it 'should do something' do
    response = @faraday.get('/ebi')
    response.body.must_equal('foo')
  end

end
