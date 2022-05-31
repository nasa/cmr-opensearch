require 'json'

class PlaceNameToPoint
  URL = 'http://api.geonames.org/searchJSON?'
  FIXED_PARAMETERS = '&username=echo_reverb&maxRows=1'

  def self.exists? place_name
    find(place_name)
  end

  def self.find(place_name)
    url = "#{URL}q=#{ERB::Util.url_encode(place_name)}#{FIXED_PARAMETERS}"
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body

    result = JSON.parse(data)
    location = nil
    location = result['geonames'].first if result && result['geonames']

    location
  end

  def self.add_cmr_param(params, place_name)
    location = find(place_name)
    params[:point] = "#{location['lng']},#{location['lat']}" if location
    params
  end
end