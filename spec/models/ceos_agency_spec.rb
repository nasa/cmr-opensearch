require 'spec_helper'

describe CeosAgency do
  describe "CEOS Agency" do
    it "is possible to create a CEOS Agency from a JSON string" do
      json_ceos_agency_string = '
        {
          "name": "ceos_agency_1",
          "data_centers": ["DC1", "DC2"]
        }'
      c = CeosAgency.new(json_ceos_agency_string)
      expect(c.name).to eq('ceos_agency_1')
      expect(c.data_centers).to match_array(["DC1", "DC2"])
    end
  end

  it "is possible to create two CEOS Agencies from a JSON string" do
    json_ceos_agencies_array =
    [
        '{
          "name": "ceos_agency_1",
          "data_centers": ["DC1", "DC2"]
        }',
        '{
          "name": "ceos_agency_2",
          "data_centers": ["DC3", "DC4"]
        }'
    ]
    ceos_agencies_array = CeosAgency.create_all_ceos_agencies(json_ceos_agencies_array)
    expect(ceos_agencies_array.length).to eq(2)
    first_agency = ceos_agencies_array[0]
    second_agency = ceos_agencies_array[1]
    expect(first_agency.name).to eq('ceos_agency_1')
    expect(first_agency.data_centers).to match_array(["DC1", "DC2"])
    expect(second_agency.name).to eq('ceos_agency_2')
    expect(second_agency.data_centers).to match_array(["DC3", "DC4"])
  end

  it "is possible to create a CMR query string from a JSON string" do
    json_ceos_agencies_array =
        [
            '{
          "name": "ceos_agency_1",
          "data_centers": ["DC1", "DC2"]
        }',
            '{
          "name": "ceos_agency_2",
          "data_centers": ["DC3", "DC4"]
        }'
        ]
    escaped_cmr_query_string = CeosAgency.create_all_ceos_agencies_cmr_query_string(json_ceos_agencies_array).to_query
    unescaped_cmr_query_string = URI::decode_www_form_component(escaped_cmr_query_string)
    expected_unescaped_query_string = 'data_center[]=DC1&data_center[]=DC2&data_center[]=DC3&data_center[]=DC4&options[data_center][pattern]=true'
    expect(unescaped_cmr_query_string).to eq(expected_unescaped_query_string)
  end
end