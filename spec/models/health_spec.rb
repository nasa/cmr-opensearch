require 'spec_helper'

describe Health do
  describe 'health' do
    it 'is possible to report a good status from CMR search' do
      VCR.use_cassette 'models/health/cmr_good', :decode_compressed_response => true, :record => :once do
        h = Health.new
        expect(h.ok?).to eq(true)
      end
    end

    it 'is possible to report a bad status from CMR search due to a bad element' do
      VCR.use_cassette 'models/health/cmr_bad', :decode_compressed_response => true, :record => :once do
        h = Health.new
        expect(h.ok?).to eq(false)
      end
    end

    it 'is possible to report a good status from CMR search due to a bad status' do
      VCR.use_cassette 'models/health/cmr_bad_status', :decode_compressed_response => true, :record => :once do
        h = Health.new
        expect(h.ok?).to eq(false)
      end
    end
  end
end