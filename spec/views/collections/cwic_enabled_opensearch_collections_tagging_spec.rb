require 'spec_helper'

describe 'various provider granule OpenSearch API search behavior'  do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before (:each) do
    Flipper.enable(:use_cwic_server)
  end

  after (:all) do
    Flipper.disable(:use_cwic_server)
  end

  it 'returns CWIC OSDD links for both PROD and TEST CWIC datasets when the CWIC request header is present and and Provider Specific links when collection is appropriately tagged' do
    VCR.use_cassette 'models/tag/cmr_cwic_opensearch_datasets_prod_test_tags_mix', :decode_compressed_response => true , :record => :once do
      header 'Cwic-User', 'test'
      get '/datasets.atom?keyword=GCMDTEST&clientId=rspec12'
      expect(last_response.ok?).to be true
      feed = Nokogiri::XML(last_response.body)
      # Do we have 10 entries
      entries = feed.xpath('os:feed/os:entry', 'os' => 'http://www.w3.org/2005/Atom')
      expect(entries.size).to eq(10)
      # response entry ids and tag values are modified to reflect the tag modified 1 - PROD, 2 - TEST, ... 9 - PROD, 10 - TEST
      entries.each_with_index do |entry, index|
        entry_id = entry.at_xpath('os:id', 'os' => 'http://www.w3.org/2005/Atom').text
        # each entry has its index based ID in its id element
        expect(entry_id.include?((index+1).to_s)).to be true
        # various granule OSDDs that we can encounter
        entry_osdd_link = entry.at_xpath('os:link[@title = \'Granule OpenSearch Descriptor Document\']', 'os' => 'http://www.w3.org/2005/Atom')
        entry_tag_value = entry.at_xpath('echo:tag/echo:tagKey', 'os' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').text

        # TEST entries
        if([2,5,8].include?(index+1))
          expect(entry_tag_value).to eq('org.ceos.wgiss.cwic.granules.test')
          # test will NOT have the CWIC OSDD link when the header is NOT present
          expect(entry_osdd_link.nil?).to be false
          # since CWIC is enabled via Flipper, we are expecting a CWIC OSDD
          entry_osdd_link_string = entry_osdd_link['href']
          expect(entry_osdd_link_string).to start_with("https://cwic.wgiss.ceos.org/opensearch/datasets")

        end
        # PROD entries
        if([1,4,7,10].include?(index+1))
          expect(entry_tag_value).to eq('org.ceos.wgiss.cwic.granules.prod')
          # prod will always have the CWIC OSDD link for 'prod' tag
          expect(entry_osdd_link.nil?).to be false
          # since CWIC is enabled via Flipper, we are expecting a CWIC OSDD
          entry_osdd_link_string = entry_osdd_link['href']
          expect(entry_osdd_link_string).to start_with("https://cwic.wgiss.ceos.org/opensearch/datasets")
        end
        # OpenSearch entries
        if([3,6,9].include?(index+1))
          expect(entry_tag_value).to eq('opensearch.granule.osdd')
          expect(entry_osdd_link.nil?).to be true
        end
      end
    end
  end

  it 'returns CWIC links for PROD CWIC datasets and PROVIDER only links when the CWIC request header is NOT present' do
    VCR.use_cassette 'models/tag/cmr_cwic_opensearch_datasets_prod_test_tags_mix', :decode_compressed_response => true , :record => :once do
      # no request header so no CWIC links for CWIC test granules
      get '/datasets.atom?keyword=GCMDTEST&clientId=rspec12'
      expect(last_response.ok?).to be true
      feed = Nokogiri::XML(last_response.body)
      # Do we have 10 entries
      entries = feed.xpath('os:feed/os:entry', 'os' => 'http://www.w3.org/2005/Atom')
      expect(entries.size).to eq(10)
      # response entry ids and tag values are modified to reflect the tag modified id 1,4,7,10 - PROD, id 2,5,7 - TEST, id 3,6,9 - OpenSearch ...
      # id 9 - OpenSearch, id 10 - PROD
      entries.each_with_index do |entry, index|
        entry_id = entry.at_xpath('os:id', 'os' => 'http://www.w3.org/2005/Atom').text
        # each entry has its index based ID in its id element
        expect(entry_id.include?((index+1).to_s)).to be true
        # various granule OSDDs that we can encounter
        entry_osdd_link = entry.at_xpath('os:link[@title = \'Granule OpenSearch Descriptor Document\']', 'os' => 'http://www.w3.org/2005/Atom')
        entry_tag_value = entry.at_xpath('echo:tag/echo:tagKey', 'os' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').text
        # TEST entries
        if([2,5,8].include?(index+1))
          expect(entry_tag_value).to eq('org.ceos.wgiss.cwic.granules.test')
          # test will NOT have the CWIC OSDD link when the header is NOT present
          expect(entry_osdd_link.nil?).to be true
        end
        # PROD entries
        if([1,4,7,10].include?(index+1))
          expect(entry_tag_value).to eq('org.ceos.wgiss.cwic.granules.prod')
          # prod will always have the CWIC OSDD link for 'prod' tag
          expect(entry_osdd_link.nil?).to be false
          # since CWIC is enabled via Flipper, we are expecting a CWIC OSDD
          entry_osdd_link_string = entry_osdd_link['href']
          expect(entry_osdd_link_string).to start_with("https://cwic.wgiss.ceos.org/opensearch/datasets")

        end
        # OpenSearch entries
        if([3,6,9].include?(index+1))
          expect(entry_tag_value).to eq('opensearch.granule.osdd')
          expect(entry_osdd_link.nil?).to be true
        end
      end
    end
  end
end
