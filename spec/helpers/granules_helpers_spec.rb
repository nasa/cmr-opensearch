require 'spec_helper'

describe GranulesHelper do
  describe 'determine_granule_url' do
    it 'should return a url from related urls when it exists' do
      graphql_metadata = {
        'id' => 'C0000000001-OPENSEARCH',
        'relatedUrls' => [{
          'urlContentType' => 'DistributionURL',
          'subtype' => 'OpenSearch',
          'url' => 'https://cmr.earthdata.nasa.gov/opensearch/atom.xml?datasetId=fromRelatedUrls'
        }]
      }

      granule_url = determine_granule_url(graphql_metadata)

      expect(granule_url).to eq('https://cmr.earthdata.nasa.gov/opensearch/atom.xml?datasetId=fromRelatedUrls')
    end

    it 'should return a url from tags when it exists and related urls do not' do
      graphql_metadata = {
        'id' => 'C0000000001-OPENSEARCH',
        'tags' => {
          'opensearch.granule.osdd' => {
            'data' => 'https://cmr.earthdata.nasa.gov/opensearch/atom.xml?datasetId=fromTags'
          }
        }
      }

      granule_url = determine_granule_url(graphql_metadata)

      expect(granule_url).to eq('https://cmr.earthdata.nasa.gov/opensearch/atom.xml?datasetId=fromTags')
    end

    it 'should return a url from related urls when it exists but tags also exist' do
      graphql_metadata = {
        'id' => 'C0000000001-OPENSEARCH',
        'relatedUrls' => [{
          'urlContentType' => 'DistributionURL',
          'subtype' => 'OpenSearch',
          'url' => 'https://cmr.earthdata.nasa.gov/opensearch/atom.xml?datasetId=fromRelatedUrls'
        }],
        'tags' => {
          'opensearch.granule.osdd' => {
            'data' => 'https://cmr.earthdata.nasa.gov/opensearch/atom.xml?datasetId=fromTags'
          }
        }
      }

      granule_url = determine_granule_url(graphql_metadata)

      expect(granule_url).to eq('https://cmr.earthdata.nasa.gov/opensearch/atom.xml?datasetId=fromRelatedUrls')
    end
  end
end
