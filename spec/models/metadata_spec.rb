require 'spec_helper'

describe Metadata do
  before(:each) do
    @m = Metadata.new
  end
  describe 'navigation' do
    it 'should return boolean representing whether next and previous link is appropriate given cursor, numberOfResults and hits' do
      params = {:cursor => '2', :numberOfResults => '10'}
      hits = 35
      assert @m.need_prev_cursor?(params)
      assert @m.need_next_cursor?(params, hits)

      params[:cursor] = '1'
      assert !@m.need_prev_cursor?(params)
      assert @m.need_next_cursor?(params, hits)

      params[:cursor] = '3'
      assert @m.need_prev_cursor?(params)
      assert @m.need_next_cursor?(params, hits)

      params[:cursor] = '4'
      assert @m.need_prev_cursor?(params)
      assert !@m.need_next_cursor?(params, hits)

      hits = 30

      params[:cursor] = '3'
      assert @m.need_prev_cursor?(params)
      assert !@m.need_next_cursor?(params, hits)

      params[:cursor] = nil
      assert !@m.need_prev_cursor?(params)
      assert @m.need_next_cursor?(params, hits)

      params.delete :cursor
      assert !@m.need_prev_cursor?(params)
      assert @m.need_next_cursor?(params, hits)
    end
  end

  it 'should return boolean representing whether next and previous link is appropriate given offser, numberOfResults and hits' do
    params = {:offset => '2', :numberOfResults => '10'}
    hits = 35
    assert !@m.need_prev_offset?(params, hits)
    assert @m.need_next_offset?(params, hits)

    params[:offset] = '32'
    assert @m.need_prev_offset?(params, hits)
    assert !@m.need_next_offset?(params, hits)

    params[:offset] = '35'
    assert @m.need_prev_offset?(params, hits)
    assert !@m.need_next_offset?(params, hits)

    hits = 30

    params[:offset] = '30'
    assert @m.need_prev_offset?(params, hits)
    assert !@m.need_next_offset?(params, hits)
  end

  describe 'open search to echo parameter conversion' do
    it 'should convert cursor to page_num and 0 to 1' do
      open_search_params = {:cursor => 1}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:page_num]).to eq(1)

      open_search_params = {:cursor => 0}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:page_num]).to eq(1)

      open_search_params = {:cursor => -1}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:page_num]).to eq(1)

      open_search_params = {:cursor => 10}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:page_num]).to eq(10)
    end

    it 'should convert numberOfResults to page_size' do
      open_search_params = {:numberOfResults => 1}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:page_size]).to eq(1)
    end

    it 'should convert instrument to instrument' do
      open_search_params = {:instrument => 'MODIS'}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:instrument]).to eq('MODIS')
    end

    it 'should convert satellite to platform' do
      open_search_params = {:satellite => 'MODIS'}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:platform]).to eq('MODIS')
    end

    it 'should convert boundingBox to bounding_box' do
      open_search_params = {:boundingBox => '10, 20, 30, 40'}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:bounding_box]).to eq('10,20,30,40')
    end

    it 'should convert startTime and endTime to temporal' do
      open_search_params = {:startTime => '1999-12-18T00:00:00.000Z', :endTime => '2000-12-18T00:00:00.000Z'}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:temporal]).to eq('1999-12-18T00:00:00.000Z,2000-12-18T00:00:00.000Z')

      open_search_params = {:endTime => '2000-12-18T00:00:00.000Z'}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:temporal]).to eq(',2000-12-18T00:00:00.000Z')

      open_search_params = {:startTime => '1999-12-18T00:00:00.000Z'}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:temporal]).to eq('1999-12-18T00:00:00.000Z,')
    end

    it 'should convert multiple parameters' do
      open_search_params = {:startTime => '1999-12-18T00:00:00.000Z',
                            :endTime => '2000-12-18T00:00:00.000Z',
                            :boundingBox => '10, 20, 30, 40',
                            :instrument => 'MODIS'}
      actual = @m.to_cmr_params open_search_params
      expect(actual[:temporal]).to eq('1999-12-18T00:00:00.000Z,2000-12-18T00:00:00.000Z')
      expect(actual[:bounding_box]).to eq('10,20,30,40')
      expect(actual[:instrument]).to eq('MODIS')
    end

  end
  describe 'failing on invalid parameters' do
    it 'should remove the invalid parameter foo from the model' do
      params = {:foo => 'bar'}
      granule = Metadata.new(params)
      expect(granule.valid?).to eq(true)
      expect(granule.errors[:foo]).to eq([])
    end
    it 'expects to fail validations on non alphanumeric clientID' do
      params = {:clientId => '%&*@*'}
      granule = Metadata.new(params)
      expect(granule.valid?).to eq(false)
    end

    it 'expects to pass validations for alphanumeric clientIDs with underscores and dashes' do
      granule_a = Metadata.new(:clientId => 'cwic_1')
      granule_b = Metadata.new(:clientId => 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-01234567892349')
      expect(granule_a.valid?).to eq(true)
      expect(granule_b.valid?).to eq(true)
    end
  end

  describe 'startIndex calculation from page cursor' do
    it 'should calculate the correct start index given the number of results and the page number' do
      granule = Metadata.new(:clientId => 'cwic_1')
      expect(granule.to_start_index(2, 10)).to eq(11)
      expect(granule.to_start_index(2, 5)).to eq(6)
      expect(granule.to_start_index(1, 5)).to eq(1)
      expect(granule.to_start_index(3, 11)).to eq(23)
    end
  end
end