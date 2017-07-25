require 'spec_helper'

describe 'collection result set navigation behavior' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it 'navigation links by cursor (pageNumber) and numberOfResults (pageSize)are rendered correctly for the CMROS-1 case' do
    VCR.use_cassette 'views/collection/navigation_cursor', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?cursor=2&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '31583', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
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
    VCR.use_cassette 'views/collection/navigation_offset', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?offset=12&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '31583', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
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

  # SCENARIO 1
  # INPUT: offset = 12, hits = 20, page_size = 10
  # LINKS: self = 12, previous = 2, first = 2, last = 12, NO NEXT
  it 'generates correct offset navigation links for collections scenario 1' do
    VCR.use_cassette 'views/collection/navigation_offset_1', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?offset=12&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '20', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '13', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert feed.xpath('atom:feed/atom:link[@rel=\'self\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=12')
      assert feed.xpath('atom:feed/atom:link[@rel=\'last\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=12')
      assert feed.xpath('atom:feed/atom:link[@rel=\'previous\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=2')
      assert feed.xpath('atom:feed/atom:link[@rel=\'first\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=2')
      # no next link
      assert feed.xpath('atom:feed/atom:link[@rel=\'next\']', 'atom' => 'http://www.w3.org/2005/Atom').size == 0
      # Make sure we have the right namespace for georss
      assert feed.namespaces.has_value?('http://www.georss.org/georss')
      assert !feed.namespaces.has_value?('http://www.georss.org/georss/10')
    end
  end

  # SCENARIO 2
  # INPUT offset = 12, hits = 24, page_size = 10
  # LINKS self = 12, previous = 2, first = 2, last = 22, next = 22
  it 'generates correct offset navigation links for collections scenario 2' do
    VCR.use_cassette 'views/collection/navigation_offset_2', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?offset=12&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '24', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '13', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert feed.xpath('atom:feed/atom:link[@rel=\'self\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=12')
      assert feed.xpath('atom:feed/atom:link[@rel=\'last\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=22')
      assert feed.xpath('atom:feed/atom:link[@rel=\'previous\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=2')
      assert feed.xpath('atom:feed/atom:link[@rel=\'first\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=2')
      assert feed.xpath('atom:feed/atom:link[@rel=\'next\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=22')
      # Make sure we have the right namespace for georss
      assert feed.namespaces.has_value?('http://www.georss.org/georss')
      assert !feed.namespaces.has_value?('http://www.georss.org/georss/10')
    end
  end

  # SCENARIO 3
  # INPUT offset = 12, hits = 12, page_size = 10
  # LINKS self = 12, previous = 2, first = 2, last = 12, NO NEXT
  it 'generates correct offset navigation links for collections scenario 3' do
    VCR.use_cassette 'views/collection/navigation_offset_3', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?offset=12&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '12', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '13', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert feed.xpath('atom:feed/atom:link[@rel=\'self\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=12')
      assert feed.xpath('atom:feed/atom:link[@rel=\'last\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=12')
      assert feed.xpath('atom:feed/atom:link[@rel=\'previous\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=2')
      assert feed.xpath('atom:feed/atom:link[@rel=\'first\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=2')
      # no next link
      assert feed.xpath('atom:feed/atom:link[@rel=\'next\']', 'atom' => 'http://www.w3.org/2005/Atom').size == 0
      # Make sure we have the right namespace for georss
      assert feed.namespaces.has_value?('http://www.georss.org/georss')
      assert !feed.namespaces.has_value?('http://www.georss.org/georss/10')
    end
  end

  # SCENARIO 4
  # INPUT offset = 12, hits = 0, page_size = 10
  # LINKS SELF only
  it 'generates correct offset navigation links for collections scenario 4' do
    VCR.use_cassette 'views/collection/navigation_offset_4', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?offset=12&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '0', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').size == 0
      assert feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').size == 0
      assert feed.xpath('atom:feed/atom:link[@rel=\'self\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=12')
      assert feed.xpath('atom:feed/atom:link[@rel=\'last\']', 'atom' => 'http://www.w3.org/2005/Atom').size == 0
      assert feed.xpath('atom:feed/atom:link[@rel=\'previous\']', 'atom' => 'http://www.w3.org/2005/Atom').size == 0
      assert feed.xpath('atom:feed/atom:link[@rel=\'first\']', 'atom' => 'http://www.w3.org/2005/Atom').size == 0
      assert feed.xpath('atom:feed/atom:link[@rel=\'next\']', 'atom' => 'http://www.w3.org/2005/Atom').size == 0
      # Make sure we have the right namespace for georss
      assert feed.namespaces.has_value?('http://www.georss.org/georss')
      assert !feed.namespaces.has_value?('http://www.georss.org/georss/10')
    end
  end

  # SCENARIO 5
  # INPUT offset = 12, hits = 22, page_size = 10
  # LINKS self = 12, previous = 2, first = 2, last = 22, next = 22
  it 'generates correct offset navigation links for collections scenario 5' do
    VCR.use_cassette 'views/collection/navigation_offset_5', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?offset=12&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '22', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '13', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert feed.xpath('atom:feed/atom:link[@rel=\'self\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=12')
      assert feed.xpath('atom:feed/atom:link[@rel=\'last\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=22')
      assert feed.xpath('atom:feed/atom:link[@rel=\'previous\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=2')
      assert feed.xpath('atom:feed/atom:link[@rel=\'first\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=2')
      assert feed.xpath('atom:feed/atom:link[@rel=\'next\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=22')
      # Make sure we have the right namespace for georss
      assert feed.namespaces.has_value?('http://www.georss.org/georss')
      assert !feed.namespaces.has_value?('http://www.georss.org/georss/10')
    end
  end

  # SCENARIO 6
  # INPUT offset = 12, hits = 22, page_size = 2
  # LINKS self = 12, previous = 10, first = 0, last = 22, next = 14
  it 'generates correct offset navigation links for collections scenario 6' do
    VCR.use_cassette 'views/collection/navigation_offset_6', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?offset=12&dataCenter=EDF_OPS&numberOfResults=2&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '22', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '2', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '13', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert feed.xpath('atom:feed/atom:link[@rel=\'self\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=12')
      assert feed.xpath('atom:feed/atom:link[@rel=\'last\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=22')
      assert feed.xpath('atom:feed/atom:link[@rel=\'previous\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=10')
      assert feed.xpath('atom:feed/atom:link[@rel=\'first\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=0')
      assert feed.xpath('atom:feed/atom:link[@rel=\'next\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=14')
      # Make sure we have the right namespace for georss
      assert feed.namespaces.has_value?('http://www.georss.org/georss')
      assert !feed.namespaces.has_value?('http://www.georss.org/georss/10')
    end
  end

  # SCENARIO 7
  # INPUT offset = 12, hits = 220, page_size = 10
  # LINKS self = 12, previous = 2, first = 2, last = 212, next = 24
  it 'generates correct offset navigation links for collections scenario 7' do
    VCR.use_cassette 'views/collection/navigation_offset_7', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?offset=12&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '220', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '13', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert feed.xpath('atom:feed/atom:link[@rel=\'self\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=12')
      assert feed.xpath('atom:feed/atom:link[@rel=\'last\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=212')
      assert feed.xpath('atom:feed/atom:link[@rel=\'previous\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=2')
      assert feed.xpath('atom:feed/atom:link[@rel=\'first\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=2')
      assert feed.xpath('atom:feed/atom:link[@rel=\'next\']', 'atom' => 'http://www.w3.org/2005/Atom').first['href'].include?('offset=22')
      # Make sure we have the right namespace for georss
      assert feed.namespaces.has_value?('http://www.georss.org/georss')
      assert !feed.namespaces.has_value?('http://www.georss.org/georss/10')
    end
  end

  # zero offset is the default
  it 'no offset returns ALL results' do
    VCR.use_cassette 'views/collection/navigation_no_offset', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '32279', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '1', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal 'C1214621811-SCIOPS', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[0].text
      assert_equal 'C1214587974-SCIOPS', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[1].text
      assert_equal 'C1214305813-AU_AADC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[2].text
    end
  end

  # can specify a zero offset and we get the default behavior
  it 'zero offset returns ALL results' do
    VCR.use_cassette 'views/collection/navigation_zero_offset', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3&offset=0'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '32279', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '1', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal 'C1214621811-SCIOPS', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[0].text
      assert_equal 'C1214587974-SCIOPS', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[1].text
      assert_equal 'C1214305813-AU_AADC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[2].text
    end
  end

  # offset 1 skips first result
  it 'offset 1 skips first result result' do
    VCR.use_cassette 'views/collection/navigation_1_offset', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3&offset=1'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '32287', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '2', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      # the first result is skipped due to the offset value
      #assert_equal 'C1214621811-SCIOPS', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[0].text
      assert_equal 'C1214587974-SCIOPS', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[0].text
      assert_equal 'C1214305813-AU_AADC', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[1].text
      assert_equal 'C1214608509-SCIOPS', feed.xpath('atom:feed/atom:entry/dc:identifier', 'dc' => 'http://purl.org/dc/terms/', 'atom' => 'http://www.w3.org/2005/Atom')[2].text
    end
  end

  it 'offset 32286 skips 32286 results' do
    VCR.use_cassette 'views/collection/navigation_32286_offset', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3&offset=32286'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '32287', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '32287', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal 1, feed.xpath('atom:feed/atom:entry', 'atom' => 'http://www.w3.org/2005/Atom').size
    end
  end

  # ofset = hits skips all results
  it 'offset 32287 skips ALL 32287 results' do
    VCR.use_cassette 'views/collection/navigation_32287_offset', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3&offset=32287'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '32287', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '32288', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      # there are no entries in the atom feed
      assert_equal 0, feed.xpath('atom:feed/atom:entry', 'atom' => 'http://www.w3.org/2005/Atom').size
    end
  end

  # offset > hits skips all results
  it 'offset 32288 skips ALL 32287 results' do
    VCR.use_cassette 'views/collection/navigation_32288_offset', :decode_compressed_response => true, :record => :once do
      get '/collections.atom?&dataCenter=EDF_OPS&numberOfResults=10&shortName=AST_L1B&spatial_type=bbox&versionId=3&offset=32288'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      assert_equal '32287', feed.xpath('atom:feed/os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '10', feed.xpath('atom:feed/os:itemsPerPage', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      assert_equal '32289', feed.xpath('atom:feed/os:startIndex', 'os' => 'http://a9.com/-/spec/opensearch/1.1/', 'atom' => 'http://www.w3.org/2005/Atom').first.text
      # there are no entries in the atom feed
      assert_equal 0, feed.xpath('atom:feed/atom:entry', 'atom' => 'http://www.w3.org/2005/Atom').size
    end
  end
end
