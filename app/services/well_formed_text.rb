require 'rgeo'

class WellFormedText
  def self.add_cmr_param (params, well_known_text)
    factory = RGeo::Cartesian.factory

    geometry = factory.parse_wkt(well_known_text)

    params[:point] = "#{geometry.x},#{geometry.y}" if ::RGeo::Feature::Point.check_type(geometry)
    if ::RGeo::Feature::LineString.check_type(geometry)
      params[:line] = ''
      geometry.points.each do |point|
        params[:line] += "#{point.x},#{point.y},"
      end
      params[:line].chop!
    end
    if ::RGeo::Feature::Polygon.check_type(geometry)
      params[:polygon] = ''
      geometry.exterior_ring.points.reverse_each do |point|
        params[:polygon] += "#{point.x},#{point.y},"
      end
      params[:polygon].chop!
    end
    params
  end

  def self.to_wkt(param)

  end
end