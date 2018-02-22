class CeosAgency
  attr_accessor :name, :data_centers

  # JSON string format is:
  # '
  #{
  #    "name": "ceos_agency_11",
  #    "data_centers": ["DC1", "DC2"]
  #}'
  def initialize(json_string)
    json_hash = JSON.parse(json_string)
    @name = json_hash['name']
    @data_centers = json_hash['data_centers']
  end

  # JSON array format is:
  #[
  #'{
  #        "name": "ceos_agency_1",
  #        "data_centers": ["DC1", "DC2"]
  #      }',
  #    '{
  #        "name": "ceos_agency_2",
  #        "data_centers": ["DC3", "DC4"]
  #      }'
  #]
  def self.create_all_ceos_agencies_cmr_query_string(array_of_json_strings)
    cmr_query_params = {}
    query_data_centers = cmr_query_params['data_center']
    #query_archive_centers = cmr_query_params['archive_center']
    ceos_agencies_array = CeosAgency.create_all_ceos_agencies(array_of_json_strings)
    if (ceos_agencies_array != nil && !ceos_agencies_array.empty?)
      ceos_agencies_array.each do |ceos_agency|
        agency_data_centers = ceos_agency.data_centers
        if !agency_data_centers.empty?
          agency_data_centers.each do |agency_data_center|
            if query_data_centers.nil?
              query_data_centers = Array.new
            end
            query_data_centers << agency_data_center
          end
        end
      end
      if(query_data_centers != nil && !query_data_centers.empty?)
        if cmr_query_params[:data_center].nil?
          cmr_query_params[:data_center] = query_data_centers
          # add wilcard support for data_center
          if cmr_query_params['options[data_center][pattern]'].nil?
            cmr_query_params['options[data_center][pattern]'] = true
          end  
        else
          cmr_query_params[:data_center].concat(query_data_centers)
        end
      end
    end
    return cmr_query_params
  end

  # JSON array format is:
  #[
  #'{
  #        "name": "ceos_agency_1",
  #        "data_centers": ["DC1", "DC2"]
  #      }',
  #    '{
  #        "name": "ceos_agency_2",
  #        "data_centers": ["DC3", "DC4"]
  #      }'
  #]
  def self.create_all_ceos_agencies(array_of_ceos_agencies_json_strings)
    all_ceos_agencies = Array.new
    array_of_ceos_agencies_json_strings.each do |agency_json_string|
      agency = CeosAgency.new(agency_json_string)
      all_ceos_agencies << agency
    end
    return all_ceos_agencies
  end
  end