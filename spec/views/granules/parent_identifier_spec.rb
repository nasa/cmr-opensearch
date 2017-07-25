require 'spec_helper'

describe 'granule search by parent concept-id'  do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it 'retrieves all granules for the MOD-2QKM.005 collection when using its CMR concept_id value as the CMR OpenSearch parentIdentifier query parameter value' do
    VCR.use_cassette 'views/granule/parentIdentifier', :record => :once, :decode_compressed_response => true do
      # concept_id for MOD02QKM version 5 is C90758174-LAADS at https://cmr.earthdata.nasa.gov/search/concepts/C90758174-LAADS.xml
      # 971348 hits
      granule_opensearch_response = get '/granules.atom?parentIdentifier=C90758174-LAADS&clientId=openSearchSpecTest'
      assert granule_opensearch_response.ok?
      feed = Nokogiri::XML(granule_opensearch_response.body)
      total_results = feed.at_xpath('//atom:feed/os:totalResults', 'atom' => 'http://www.w3.org/2005/Atom', 'os' => 'http://a9.com/-/spec/opensearch/1.1/').text
      assert_equal '971348', total_results
    end
  end
end