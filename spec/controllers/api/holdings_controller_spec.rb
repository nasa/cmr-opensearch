require 'spec_helper'

describe HoldingsController do

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    # Rails.cache.clear
  end

  after do
    Rails.cache.clear
  end

  describe "GET 'index'" do
    describe "When entries for configured providers dont exist in the cache" do
      it 'when' do
        get 'index', :format => :json

        expect(response.status).to eq(200)
        expect(response.body).to eq('{"test":{"collections":0,"granules":0,"last_error":null,"last_requested_at":null,"updated_at":null}}')
      end
    end

    describe "When entries for configured providers do exist in the cache" do
      it 'returns a concatenated granule count' do
        # Write a payload to the cache
        Rails.cache.write('holdings-test', {
          'count' => 3,
          'last_requested_at' => '1984-07-02T08:00:00Z',
          'updated_at' => '1984-07-15T08:00:00Z',
          'items' => {
            'C10000000-CMR' => {
              'count' => 245,
              'updated_at' => '1984-07-04T08:00:00Z'
            },
            'C10000001-CMR' => {
              'count' => 5,
              'updated_at' => '1984-07-31T08:00:00Z'
            },
            'C10000002-CMR' => {
              'last_error': 'Granule search failed after 0.704185 seconds with message "400 Bad Request" (URL: https://fedeo.ceos.org/opensearch/request?httpAccept=application%2Fatom%2Bxml&parentIdentifier=EOP:VITO:PDF:urn:ogc:def:EOP:VITO:VGT_S10)).',
              'last_requested_at': '2022-07-18T20:20:32Z'
            }
          }
        })

        get 'index', :format => :json

        expect(response.status).to eq(200)
        expect(response.body).to eq('{"test":{"collections":3,"granules":250,"last_error":null,"last_requested_at":"1984-07-02T08:00:00Z","updated_at":"1984-07-15T08:00:00Z"}}')
      end
    end
  end
end
