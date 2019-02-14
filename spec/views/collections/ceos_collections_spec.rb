require 'spec_helper'

describe 'CEOS collections searches', :type => :controller  do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it 'returns CEOS collections in the result set when isCeos is true' do
    VCR.use_cassette 'views/collection/ceos_collections', :decode_compressed_response => true , :record => :once do
      get '/collections.atom?isCeos=true'
      expect(last_response.ok?).to be true
      feed = Nokogiri::XML(last_response.body)
      # Do we have 10 entries
      entries = feed.xpath('os:feed/os:entry', 'os' => 'http://www.w3.org/2005/Atom')
      expect(entries.size).to eq(10)
      # response entries are all CEOS collections
      entries.each_with_index do |entry, index|
        entry_is_ceos = entry.at_xpath('echo:is_ceos', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').text
        expect(entry_is_ceos).to eq('true')
      end
    end
  end

end
