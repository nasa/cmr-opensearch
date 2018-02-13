require 'spec_helper'

describe 'ESIP Best Practices up link from granule search result set'  do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it 'correctly creates an up link for granule search results which contain granules from a single data set' do
    VCR.use_cassette 'views/granule/correct_up_link', :record => :once do
      granule_opensearch_response = get '/granules.atom?shortName=MODISA_L3m_CHL&versionId=2014&dataCenter=OB_DAAC&startTime=2005-01-01T00%3A00%3A01Z&endTime=2005-01-01T23%3A59%3A59Z&clientId=goodUplink'
      assert granule_opensearch_response.ok?
      feed = Nokogiri::XML(granule_opensearch_response.body)
      feed_up_link = feed.xpath('//atom:feed/atom:link[@rel="up"]', 'atom' => 'http://www.w3.org/2005/Atom')
      assert_equal 1, feed_up_link.size
    end
  end

  it 'does not create an up link for granule search results which contain granules from multiple data sets' do
    VCR.use_cassette 'views/granule/no_gran_up_link', :record => :once do
      granule_opensearch_response = get '/granules.atom?dataCenter=OB_DAAC&&startTime=2005-01-01T00%3A00%3A01Z&endTime=2005-01-01T23%3A59%3A59Z&clientId=noGranUplink'
      assert granule_opensearch_response.ok?
      feed = Nokogiri::XML(granule_opensearch_response.body)
      feed_root_links = feed.xpath('//atom:feed/atom:link', 'atom' => 'http://www.w3.org/2005/Atom')
      feed_root_links.each do |link|
        rel = link['rel']
        expect(rel).not_to equal('up')
      end
    end
  end

  it 'does not create an up link for dataset search results' do
    VCR.use_cassette 'views/granule/no_ds_up_link', :record => :once do
      granule_opensearch_response = get '/datasets.atom?keyword=MODIS&startTime=2011-01-01T00:00:00Z&endTime=2011-01-02T00:00:00Z&clientId=noDatasetsUplink'
      assert granule_opensearch_response.ok?
      feed = Nokogiri::XML(granule_opensearch_response.body)
      feed_root_links = feed.xpath('//atom:feed/atom:link', 'atom' => 'http://www.w3.org/2005/Atom')
      feed_root_links.each do |link|
        rel = link['rel']
        expect(rel).not_to equal('up')
      end
    end
  end
end