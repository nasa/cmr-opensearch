require 'spec_helper'

describe 'faceted search behavior', :type => :controller  do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it 'returns CWIC OSDD links for both PROD and TEST CWIC datasets when the request header is present' do
    VCR.use_cassette 'models/tag/cmr_cwic_datasets_prod_test_tags_mix', :decode_compressed_response => true , :record => :once do
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
        entry_link = entry.at_xpath('os:link[@title = \'Granule OpenSearch Descriptor Document\']', 'os' => 'http://www.w3.org/2005/Atom')
        # all entries will have the CWIC OSDD link since the header is present
        expect(entry_link.nil?).to be false
        entry_tag_value = entry.at_xpath('echo:tag/echo:tagKey', 'os' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').text
        # even entries are test entries, odd entries are prod entries
        if((index+1)%2 == 0)
          expect(entry_tag_value).to eq('org.ceos.wgiss.cwic.granules.test')
        end
        if((index+1)%2 == 1)
          expect(entry_tag_value).to eq('org.ceos.wgiss.cwic.granules.prod')
        end
      end
    end
  end

  it 'returns CWIC OSDD links for PROD CWIC datasets only when the request header is NOT present' do
    VCR.use_cassette 'models/tag/cmr_cwic_datasets_prod_test_tags_mix', :decode_compressed_response => true , :record => :once do
      # no request header so no CWIC links for CWIC test granules
      get '/datasets.atom?keyword=GCMDTEST&clientId=rspec12'
      expect(last_response.ok?).to be true
      feed = Nokogiri::XML(last_response.body)
      # Do we have 10 entries
      entries = feed.xpath('os:feed/os:entry', 'os' => 'http://www.w3.org/2005/Atom')
      expect(entries.size).to eq(10)
      # response entry ids and tag values are modified to reflect the tag modified id 1 - PROD, id 2 - TEST, ...
      # id 9 - PROD, id 10 - TEST
      entries.each_with_index do |entry, index|
        entry_id = entry.at_xpath('os:id', 'os' => 'http://www.w3.org/2005/Atom').text
        # each entry has its index based ID in its id element
        expect(entry_id.include?((index+1).to_s)).to be true
        entry_link = entry.at_xpath('os:link[@title = \'Granule OpenSearch Descriptor Document\']', 'os' => 'http://www.w3.org/2005/Atom')

        entry_tag_value = entry.at_xpath('echo:tag/echo:tagKey', 'os' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').text
        # even entries are test entries, odd entries are prod entries
        if((index+1)%2 == 0)
          expect(entry_tag_value).to eq('org.ceos.wgiss.cwic.granules.test')
          # test will NOT have the CWIC OSDD link when the header is NOT present
          expect(entry_link.nil?).to be true
        end
        if((index+1)%2 == 1)
          expect(entry_tag_value).to eq('org.ceos.wgiss.cwic.granules.prod')
          # prod will always have the CWIC OSDD link for 'prod' tag
          expect(!entry_link.nil?).to be true
        end
      end
    end
  end

  it 'returns CWIC OSDD links with the new CMR concept-id instead of the legacy diff-id' do
    expected_concept_ids = %w(C1239566345-EUMETSAT C1214598104-SCIOPS C1225774163-EUMETSAT C1225779016-EUMETSAT C1225782892-EUMETSAT C1226051802-EUMETSAT C1225778252-EUMETSAT C1225778362-EUMETSAT C1225778383-EUMETSAT C1225762738-EUMETSAT)
    VCR.use_cassette 'models/tag/cmr_cwic_datasets_concept_id', :decode_compressed_response => true , :record => :once do
      # look for CWIC datasets only
      get '/datasets.atom?clientId=rspec13&isCwic=true&hasGranules=false'
      expect(last_response.ok?).to be true
      feed = Nokogiri::XML(last_response.body)
      # Do we have 10 entries
      entries = feed.xpath('os:feed/os:entry', 'os' => 'http://www.w3.org/2005/Atom')
      expect(entries.size).to eq(10)
      entries.each_with_index do |entry, index|
        entry_id = entry.at_xpath('os:id', 'os' => 'http://www.w3.org/2005/Atom').text
        # entry ID uses the concept-id
        expect(entry_id).to eq("#{ENV['opensearch_url']}/collections.atom?uid=" + expected_concept_ids[index])
        # GCMD dif link used the dif-id
        get_dif_link = entry.at_xpath('os:link[@rel = \'enclosure\']', 'os' => 'http://www.w3.org/2005/Atom')
        # CWIC OSDD link uses the concept-id
        entry_link = entry.at_xpath('os:link[@title = \'Granule OpenSearch Descriptor Document\']', 'os' => 'http://www.w3.org/2005/Atom')
        entry_tag_value = entry.at_xpath('echo:tag/echo:tagKey', 'os' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').text
        expect(entry_tag_value).to include('org.ceos.wgiss.cwic.granules.')
        expect(entry_link['href']).to include(expected_concept_ids[index])
        # concept-id used in the cwic entry link is different from the dif-id
        expect(get_dif_link['href']).not_to include(expected_concept_ids[index])
      end
    end
  end
end
