require 'spec_helper'

describe 'granule data links disambiguation'  do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  # the CMR result contains two data links per granule, after processing it we are left with a single data link per granule
  it 'there is a single granule data access link in a correctly processed CMD granule OpenSearch result' do
    VCR.use_cassette 'views/granule/datalinks', :record => :once do
      granule_opensearch_response = get '/granules.atom?datasetId=&shortName=MODISA_L3m_CHL&versionId=2014&dataCenter=OB_DAAC&boundingBox=&geometry=&placeName=&startTime=2005-01-01T00%3A00%3A01Z&endTime=2005-01-01T23%3A59%3A59Z&cursor=1&numberOfResults=1&uid=&clientId=openSearchSpecTest'
      assert granule_opensearch_response.ok?
      feed = Nokogiri::XML(granule_opensearch_response.body)
      feed_entries = feed.xpath('//atom:feed/atom:entry', 'atom' => 'http://www.w3.org/2005/Atom')
      feed_entries.each do |entry|
        datalinks_count = entry.xpath('atom:link[@rel="enclosure"]', 'atom' => 'http://www.w3.org/2005/Atom')
        assert_equal 1, datalinks_count.size
      end
    end
  end
end