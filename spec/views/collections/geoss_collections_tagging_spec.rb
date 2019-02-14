require 'spec_helper'

describe 'geoss search behavior' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it 'returns a GEOSS tag in the results for a GEOSS collection' do
    VCR.use_cassette 'models/tag/cmr_geoss_collections', :decode_compressed_response => true, :record => :once do
      get '/datasets.atom?keyword=geoss_test_one&clientId=geoss_test_two', nil, {'Cwic-User' => 'test'}
      expect(last_response.ok?).to be true
      feed = Nokogiri::XML(last_response.body)
      expect(feed.at_xpath('os:feed/os:entry/echo:is_geoss', 'os' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').text).to eq('true')
    end
  end
  it 'does not return a GEOSS tag in the results for a non-GEOSS collection' do
    VCR.use_cassette 'models/tag/cmr_geoss_collections', :decode_compressed_response => true, :record => :once do
      get '/datasets.atom?keyword=geoss_test_two&clientId=geoss_test_two', nil, {'Cwic-User' => 'test'}
      expect(last_response.ok?).to be true
      feed = Nokogiri::XML(last_response.body)
      expect(feed.at_xpath('os:feed/os:entry/echo:is_geoss', 'os' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')).to eq(nil)
    end
  end

  it 'does not return a GEOSS tag in the results for a non-GEOSS collection' do
    VCR.use_cassette 'models/tag/cmr_geoss_collections', :decode_compressed_response => true, :record => :once do
      get '/datasets.atom?keyword=geoss_test_three&clientId=geoss_test_three', nil, {'Cwic-User' => 'test'}
      expect(last_response.ok?).to be true
      feed = Nokogiri::XML(last_response.body)
      expect(feed.at_xpath('os:feed/os:entry/echo:is_geoss', 'os' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')).to eq(nil)
    end
  end

  it 'does return a GEOSS tag in the results for a GEOSS collection with multiple tags' do
    VCR.use_cassette 'models/tag/cmr_geoss_collections', :decode_compressed_response => true, :record => :once do
      get '/datasets.atom?keyword=geoss_test_four&clientId=geoss_test_four', nil, {'Cwic-User' => 'test'}
      expect(last_response.ok?).to be true
      feed = Nokogiri::XML(last_response.body)
      expect(feed.at_xpath('os:feed/os:entry/echo:is_geoss', 'os' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').text).to eq('true')
    end
  end
end

