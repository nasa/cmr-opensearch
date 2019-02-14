require 'spec_helper'

describe 'faceted search behavior'  do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it 'is possible to specify facetLimit = -1 and get a list of all facets and their counts in an ATOM feed format' do
    VCR.use_cassette 'models/facet/facet_limit', :record => :once do
      get '/datasets.atom?facetLimit=-1'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      # Do we have a faceted result section?
      assert_equal 1, feed.xpath('os:feed/fs:facetedResults', 'os' => 'http://www.w3.org/2005/Atom', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').size
      # Do we have 5 facets
      # We ONLY check for all 5 facets in this spec example
      facets = feed.xpath('//fs:facet', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      assert_equal 5, facets.size

      # Platform facet
      assert_equal 'Satellite', facets[1].xpath('fs:facetDisplayLabel', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'platform', facets[1].xpath('fs:index', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      terms = facets[1].xpath('fs:terms/fs:term', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      assert_equal 419, terms.size
      assert_equal 'FIELD INVESTIGATION', terms[0].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '498', terms[0].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'AQUA', terms[1].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '201', terms[1].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'Aura', terms[2].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '187', terms[2].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text

      # Instrument facet
      assert_equal 'Instrument', facets[2].xpath('fs:facetDisplayLabel', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'instrument', facets[2].xpath('fs:index', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      terms = facets[2].xpath('fs:terms/fs:term', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      assert_equal 716, terms.size
      assert_equal 'MODIS', terms[0].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '313', terms[0].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'ANALYSIS', terms[1].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '277', terms[1].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'TES', terms[2].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '182', terms[2].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text

      # campaign facet facet[0]
      assert_equal 'Campaign', facets[0].xpath('fs:facetDisplayLabel', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'project', facets[0].xpath('fs:index', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      terms = facets[0].xpath('fs:terms/fs:term', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      assert_equal 413, terms.size
      assert_equal 'EOSDIS', terms[0].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '1720', terms[0].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'ESIP', terms[1].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '1706', terms[1].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'CWIC', terms[2].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '343', terms[2].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text

      # processing_level facet facet[4]
      assert_equal 'Processing Level', facets[4].xpath('fs:facetDisplayLabel', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'processing_level_id', facets[4].xpath('fs:index', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      terms = facets[4].xpath('fs:terms/fs:term', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      assert_equal 16, terms.size
      assert_equal '3', terms[0].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '1685', terms[0].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '2', terms[1].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '538', terms[1].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '1B', terms[2].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '184', terms[2].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text

      # sensor facet facet[3]
      assert_equal 'Sensor', facets[3].xpath('fs:facetDisplayLabel', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'sensor', facets[3].xpath('fs:index', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      terms = facets[3].xpath('fs:terms/fs:term', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      assert_equal 667, terms.size
      assert_equal 'MODIS', terms[0].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '299', terms[0].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'ANALYSIS', terms[1].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '277', terms[1].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'FTS', terms[2].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '182', terms[2].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
    end
  end

  it 'is possible to specify facetLimit = -1 and retrieve all satellite facet terms and their counts' do
    VCR.use_cassette 'models/facet/all_satellite_facets', :record => :once do
      # get all facets
      get '/datasets.atom?facetLimit=-1'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)

      # Do we have a faceted result section?
      assert_equal 1, feed.xpath('os:feed/fs:facetedResults', 'os' => 'http://www.w3.org/2005/Atom', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').size

      # Do we have 5 facets
      facets = feed.xpath('//fs:facet', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      assert_equal 5, facets.size

      # get the FIELD_INVESTIGATION total count
      # satellite (platform) facet
      assert_equal 'Satellite', facets[1].xpath('fs:facetDisplayLabel', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'platform', facets[1].xpath('fs:index', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      terms = facets[1].xpath('fs:terms/fs:term', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      # support satellite facets
      assert_equal 419, terms.size
      assert_equal 'FIELD INVESTIGATION', terms[0].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '498', terms[0].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
    end
  end

  it 'is possible to specify facetLimit = 0 and have no facets in the atom response' do
    VCR.use_cassette 'models/facet/no_facets', :record => :once do
      # get all facets
      get '/datasets.atom?facetLimit=0'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      # we should not have a faceted result
      assert_equal 0, feed.xpath('os:feed/fs:facetedResults', 'os' => 'http://www.w3.org/2005/Atom', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').size
    end
  end

  it 'is possible to reduce the dataset facet count by specifying opensearch query constraints' do
    VCR.use_cassette 'models/facet/water_facets', :record => :once do
      # get all facets
      get '/datasets.atom?facetLimit=-1&keyword=water'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      # Do we have a faceted result section?
      assert_equal 1, feed.xpath('os:feed/fs:facetedResults', 'os' => 'http://www.w3.org/2005/Atom', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').size

      # Do we have 5 facets
      facets = feed.xpath('//fs:facet', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      assert_equal 5, facets.size

      # get the GPM total count
      total_gpm_count = 493
      # satellite (platform) facet
      assert_equal 'Satellite', facets[1].xpath('fs:facetDisplayLabel', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'platform', facets[1].xpath('fs:index', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      terms = facets[1].xpath('fs:terms/fs:term', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      # support 50 satellite facets
      assert_equal 152, terms.size
      assert_equal 'GPM', terms[0].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      actual_gpm_count_str = terms[0].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '178', actual_gpm_count_str
      # verify that we have in fact a smaller actualTerm count due to the OpenSearch query parameter
      assert_equal true, actual_gpm_count_str.to_i < total_gpm_count
    end
  end

  it 'is possible to specify 100 as the global facet count limit (for all facet fields) by using facetLimit=100' do
    VCR.use_cassette 'models/facet/all_facets_limit_100', :record => :once do
      # get all facets
      get '/datasets.atom?facetLimit=100'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      # Do we have a faceted result section?
      assert_equal 1, feed.xpath('os:feed/fs:facetedResults', 'os' => 'http://www.w3.org/2005/Atom', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').size

      # Do we have 5 facets
      facets = feed.xpath('//fs:facet', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      assert_equal 5, facets.size

      # get the FIELD_INVESTIGATION total count
      total_field_investigation_count = 493
      # satellite (platform) facet
      assert_equal 'Satellite', facets[1].xpath('fs:facetDisplayLabel', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'platform', facets[1].xpath('fs:index', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      terms = facets[1].xpath('fs:terms/fs:term', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      # support 50 satellite facets
      assert_equal 419, terms.size
      assert_equal 'FIELD INVESTIGATION', terms[0].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      actual_field_investigation_count_str = terms[0].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '100', actual_field_investigation_count_str
      # verify that we have in fact a smaller actualTerm count due to the OpenSearch query parameter
      assert_equal true, actual_field_investigation_count_str.to_i < total_field_investigation_count
    end
  end

  it 'is possible to specify 100 as the global facet count limit by using facetLimit=100 in addition to the opensearch query constraint' do
    VCR.use_cassette 'models/facet/water_facets_100', :record => :once do
      # get all facets
      get '/datasets.atom?facetLimit=100&keyword=water'
      assert last_response.ok?
      feed = Nokogiri::XML(last_response.body)
      # Do we have a faceted result section?
      assert_equal 1, feed.xpath('os:feed/fs:facetedResults', 'os' => 'http://www.w3.org/2005/Atom', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').size

      # Do we have 5 facets
      facets = feed.xpath('//fs:facet', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      assert_equal 5, facets.size

      # get the GPM total count
      total_gpm_count = 493
      # satellite (platform) facet
      assert_equal 'Satellite', facets[1].xpath('fs:facetDisplayLabel', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal 'platform', facets[1].xpath('fs:index', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      terms = facets[1].xpath('fs:terms/fs:term', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      # support 152 satellite facets
      assert_equal 433, terms.size
      assert_equal 'SHIPS', terms[0].xpath('fs:actualTerm', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      actual_gpm_count_str = terms[0].xpath('fs:count', 'fs' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults').first.text
      assert_equal '100', actual_gpm_count_str
      # verify that we have in fact a smaller actualTerm count due to the OpenSearch query parameter
      assert_equal true, actual_gpm_count_str.to_i < total_gpm_count
    end
  end
end
