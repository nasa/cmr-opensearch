require 'spec_helper'

describe PlaceNameToPoint do
  describe 'exists' do
    it 'should validate an existing place name' do
      VCR.use_cassette 'services/place_name_to_geometry', :record => :once do
        expect(PlaceNameToPoint.exists?("Bowness-on-solway")).to_not equal(nil)
      end

    end
    it 'should not validate an existing place name' do
      VCR.use_cassette 'services/place_name_to_geometry', :record => :once do
          expect(PlaceNameToPoint.exists?('dougopolis')).to equal(nil)
      end
    end
  end
  describe 'add_cmr_param' do
    it 'should not convert a bogus place name' do
      VCR.use_cassette 'services/place_name_to_geometry', :record => :once do
        echo_params = {}
        echo_params = PlaceNameToPoint.add_cmr_param(echo_params, 'dougopolis')
        expect(echo_params[:point]).to equal(nil)
      end
    end
  end
end