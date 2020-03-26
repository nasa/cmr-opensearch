require 'spec_helper'

describe 'collections searches compliance with CEOS Best Practices version 1.2' do
  include Rack::Test::Methods

  def app
    Rails.application
  end
  it 'unsupported query parameters are dropped from the request per CEOS-BP-009B' do
    VCR.use_cassette 'views/collection/ceos_bp_009b', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?shortName=AST_L1B&spatial_type=bbox&unsupported_query_parameter=testvalue'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '33354', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '1', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      request_node = feed.xpath('atom:feed/os:Query', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first
      expect(request_node.keys.include?('role')).to be true
      expect(request_node.keys.include?('shortName')).to be true
      expect(request_node.keys.include?('unsupported_query_parameter')).to be false
      expect(request_node.values.include?('request')).to be true
      expect(request_node.values.include?('AST_L1B')).to be true
      expect(request_node.values.include?('testvalue')).to be false
    end
  end
end
