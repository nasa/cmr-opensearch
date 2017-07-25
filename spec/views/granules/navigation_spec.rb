require 'spec_helper'

describe 'granule result set navigation behavior'  do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it 'navigation links by cursor (pageNumber) and numberOfResults (pageSize)are rendered correctly for the CMROS-1 case' do
    VCR.use_cassette 'views/granule/navigation_cursor', :record => :once do
      get '/granules.atom?cursor=2&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '27', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '11', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert feed.xpath('atom:feed/atom:link[@rel=\'self\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'last\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'previous\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'first\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'next\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      # Make sure we have the right namespace for georss

      assert feed.namespaces.has_value?('http://www.georss.org/georss')
      assert !feed.namespaces.has_value?('http://www.georss.org/georss/10')
    end
  end

  it 'navigation links by offset (startIndex) and numberOfResults (pageSize)are rendered correctly for the CMROS-1 case' do
    VCR.use_cassette 'views/granule/navigation_offset', :decode_compressed_response => true, :record => :once do
      get '/granules.atom?offset=12&numberOfResults=10&instrument=CZCS'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '95268', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '13', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert feed.xpath('atom:feed/atom:link[@rel=\'self\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'last\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'previous\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'first\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'next\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      # Make sure we have the right namespace for georss

      assert feed.namespaces.has_value?('http://www.georss.org/georss')
      assert !feed.namespaces.has_value?('http://www.georss.org/georss/10')
    end
  end

  it 'generates correct offset navigation links for granules' do
    VCR.use_cassette 'views/granule/navigation_offset_1', :decode_compressed_response => true, :record => :once do
      get '/granules.atom?offset=12&numberOfResults=10&instrument=CZCS'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '95268', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '13', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert feed.xpath('atom:feed/atom:link[@rel=\'self\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'last\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'previous\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'first\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      assert feed.xpath('atom:feed/atom:link[@rel=\'next\']', 'atom' => 'http://www.w3.org/2005/Atom').first
      # Make sure we have the right namespace for georss

      assert feed.namespaces.has_value?('http://www.georss.org/georss')
      assert !feed.namespaces.has_value?('http://www.georss.org/georss/10')
    end
  end

  # zero offset is the default
  it 'no offset returns ALL results' do
    VCR.use_cassette 'views/granule/navigation_no_offset', :decode_compressed_response => true, :record => :once do
      get '/granules.atom?numberOfResults=10&instrument=CZCS'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '95268', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '1', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal 'G1220194852-OB_DAAC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[0].text
      assert_equal 'G1220194859-OB_DAAC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[1].text
      assert_equal 'G1220194882-OB_DAAC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[2].text
    end
  end

  # can specify a zero offset and we get the default behavior
  it 'zero offset returns ALL results' do
    VCR.use_cassette 'views/granule/navigation_zero_offset', :decode_compressed_response => true, :record => :once do
      get '/granules.atom?numberOfResults=10&instrument=CZCS&offset=0'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '95268', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '1', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal 'G1220194852-OB_DAAC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[0].text
      assert_equal 'G1220194859-OB_DAAC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[1].text
      assert_equal 'G1220194882-OB_DAAC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[2].text
    end
  end

  # offset 1 skips first result
  it 'offset 1 skips first result result' do
    VCR.use_cassette 'views/granule/navigation_1_offset', :decode_compressed_response => true, :record => :once do
      get '/granules.atom?numberOfResults=10&instrument=CZCS&offset=1'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '95268', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '2', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      # first result is skipped
      #assert_equal 'G1220194852-OB_DAAC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[0].text
      assert_equal 'G1220194859-OB_DAAC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[0].text
      assert_equal 'G1220194882-OB_DAAC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[1].text
      assert_equal 'G1220194885-OB_DAAC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[2].text
    end
  end

  it 'offset 95267 skips 95267 results' do
    VCR.use_cassette 'views/granule/navigation_95267_offset', :decode_compressed_response => true, :record => :once do
      get '/granules.atom?numberOfResults=10&instrument=CZCS&offset=95267'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '95268', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '95268', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      # ensure that we have only the last entry
      assert_equal 1, feed.xpath('atom:feed/atom:entry', 'atom' => 'http://www.w3.org/2005/Atom').size
    end
  end

  # ofset = hits skips all results
  it 'offset 95268 skips ALL 95268 results' do
    VCR.use_cassette 'views/granule/navigation_95268_offset', :decode_compressed_response => true, :record => :once do
      get '/granules.atom?numberOfResults=10&instrument=CZCS&offset=95268'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '95268', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '95269', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      # ensure that we NO entries
      assert_equal 0, feed.xpath('atom:feed/atom:entry', 'atom' => 'http://www.w3.org/2005/Atom').size
    end
  end

  # offset > hits skips all results
  it 'offset 95269 skips ALL 95268 results' do
    VCR.use_cassette 'views/granule/navigation_95269_offset', :decode_compressed_response => true, :record => :once do
      get '/granules.atom?numberOfResults=10&instrument=CZCS&offset=95269'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '95268', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '95270', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      # ensure that we NO entries
      assert_equal 0, feed.xpath('atom:feed/atom:entry', 'atom' => 'http://www.w3.org/2005/Atom').size
    end
  end

  # specs for CMROS-71, see https://bugs.earthdata.nasa.gov/browse/CMROS-71
  # offset is 0-based
  it 'correctly addresses the offset navigation issue described in CMROS-71' do
    VCR.use_cassette 'views/granule/navigation_cmros-71_offset_navigation', :decode_compressed_response => true, :record => :once do

      # first request
      get '/granules.atom?shortName=Landsat_8_OLI_TIRS&dataCenter=USGS_EROS&offset=0'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)

      self_link_req_1 = feed.at_xpath('atom:feed/atom:link[@rel="self"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(self_link_req_1).not_to be_nil
      expect(self_link_req_1['href']).to include 'offset=0'

      next_link_req_1 = feed.at_xpath('atom:feed/atom:link[@rel="next"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(next_link_req_1).not_to be_nil
      expect(next_link_req_1['href']).to include 'offset=10'

      first_link_req_1 = feed.at_xpath('atom:feed/atom:link[@rel="first"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(first_link_req_1).not_to be_nil
      expect(first_link_req_1['href']).to include 'offset=0'

      last_link_req_1 = feed.at_xpath('atom:feed/atom:link[@rel="last"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(last_link_req_1).not_to be_nil
      expect(last_link_req_1['href']).to include 'offset=969980'

      # no previous link should be available, we are at offset 0
      prev_link_req_1 = feed.at_xpath('atom:feed/atom:link[@rel="previous"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(prev_link_req_1).to be_nil

      # second request
      get '/granules.atom?shortName=Landsat_8_OLI_TIRS&dataCenter=USGS_EROS&offset=10'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)

      self_link_req_2 = feed.at_xpath('atom:feed/atom:link[@rel="self"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(self_link_req_2).not_to be_nil
      expect(self_link_req_2['href']).to include 'offset=10'

      next_link_req_2 = feed.at_xpath('atom:feed/atom:link[@rel="next"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(next_link_req_2).not_to be_nil
      expect(next_link_req_2['href']).to include 'offset=20'

      first_link_req_2 = feed.at_xpath('atom:feed/atom:link[@rel="first"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(first_link_req_2).not_to be_nil
      expect(first_link_req_2['href']).to include 'offset=0'

      last_link_req_2 = feed.at_xpath('atom:feed/atom:link[@rel="last"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(last_link_req_2).not_to be_nil
      expect(last_link_req_2['href']).to include 'offset=969980'

      # previous link should be there since we start with offset 10
      prev_link_req_2 = feed.at_xpath('atom:feed/atom:link[@rel="previous"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(prev_link_req_2).not_to be_nil
      expect(prev_link_req_2['href']).to include 'offset=0'

      # third request
      get '/granules.atom?shortName=Landsat_8_OLI_TIRS&dataCenter=USGS_EROS&offset=11'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)

      self_link_req_3 = feed.at_xpath('atom:feed/atom:link[@rel="self"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(self_link_req_3).not_to be_nil
      expect(self_link_req_3['href']).to include 'offset=11'

      next_link_req_3 = feed.at_xpath('atom:feed/atom:link[@rel="next"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(next_link_req_3).not_to be_nil
      expect(next_link_req_3['href']).to include 'offset=21'

      first_link_req_3 = feed.at_xpath('atom:feed/atom:link[@rel="first"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(first_link_req_3).not_to be_nil
      expect(first_link_req_3['href']).to include 'offset=1'

      last_link_req_3 = feed.at_xpath('atom:feed/atom:link[@rel="last"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(last_link_req_3).not_to be_nil
      expect(last_link_req_3['href']).to include 'offset=969981'

      prev_link_req_3 = feed.at_xpath('atom:feed/atom:link[@rel="previous"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(prev_link_req_3).not_to be_nil
      expect(prev_link_req_3['href']).to include 'offset=1'

      # fourth request
      get '/granules.atom?shortName=Landsat_8_OLI_TIRS&dataCenter=USGS_EROS&offset=20'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      self_link_req_4 = feed.at_xpath('atom:feed/atom:link[@rel="self"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(self_link_req_4).not_to be_nil
      expect(self_link_req_4['href']).to include 'offset=20'

      next_link_req_4 = feed.at_xpath('atom:feed/atom:link[@rel="next"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(next_link_req_4).not_to be_nil
      expect(next_link_req_4['href']).to include 'offset=30'

      first_link_req_4 = feed.at_xpath('atom:feed/atom:link[@rel="first"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(first_link_req_4).not_to be_nil
      expect(first_link_req_4['href']).to include 'offset=0'

      last_link_req_4 = feed.at_xpath('atom:feed/atom:link[@rel="last"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(last_link_req_4).not_to be_nil
      expect(last_link_req_4['href']).to include 'offset=969980'

      prev_link_req_4 = feed.at_xpath('atom:feed/atom:link[@rel="previous"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom')
      expect(prev_link_req_4).not_to be_nil
      expect(prev_link_req_4['href']).to include 'offset=10'
    end
  end
end
