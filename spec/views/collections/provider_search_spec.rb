require 'spec_helper'

describe 'provider search behavior' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  # Not quite clear if provider and data_center are the same.  Some confusing explanations below:
  # archive center is a data center with a role of ARCHIVER
  # data centers can be one or more of ARCHIVER, ORIGINATOR, PROCESSOR and DISTRIBUTOR
  # Most likely, a provider is a data center with a role of ORIGINATOR, it is the data owner
  it 'returns the correct provider in the results for a provider search' do
    VCR.use_cassette 'views/collection/cmr_larc_collections', :decode_compressed_response => true, :record => :once do
      get '/datasets.atom?provider=larc&clientId=larc1', nil, {'Cwic-User' => 'test'}
      expect(last_response.ok?).to be true
      feed = Nokogiri::XML(last_response.body)
      results = feed.xpath('os:feed/os:entry/echo:dataCenter', 'os' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')
      results.each do |result|
        expect(result.text).to eq 'LARC'
      end
    end
  end
end

