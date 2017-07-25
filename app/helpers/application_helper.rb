module ApplicationHelper
  def start_hit (cursor, number_of_results, number_of_hits)
    start_hit = 0
    if cursor.to_i == 1 && number_of_hits.to_i > 0
      start_hit = 1
    elsif number_of_hits.to_i > 0
      start_hit = ((cursor.to_i - 1) * number_of_results.to_i) + 1
    end
    start_hit
  end

  def stop_hit (cursor, length, number_of_results, number_of_hits)
    #cursor = 1 if cursor < 1
    stop_hit = (cursor.to_i - 1) * number_of_results.to_i
    stop_hit += number_of_results.to_i if cursor.to_i > 1

    stop_hit = 0 if stop_hit < 1
    stop_hit = number_of_results.to_i if stop_hit == 0 and number_of_results.to_i > 0
    stop_hit = number_of_hits if stop_hit > number_of_hits.to_i
    stop_hit
  end

  def previous_page(cursor)
    cursor.to_i - 1
  end

  def next_page(cursor)
    cursor.to_i + 1
  end

  def render_temporal_extent(range)
    # Example: 1951-01-01T00:00:00Z/1952-12-01T00:00:00Z
    markup = ''
    unless range.nil?
      start = range.split('/')[0]
      stop = range.split('/')[1]
      markup = '<div>'
      markup += "<div class='group-meta'><span>Start:</span> <span class='temporal-extent-start'>#{start}</span></div>" unless start.nil? or start.to_str.nil? or start == ''
      markup += "<div class='group-meta'><span>End:</span> <span class='temporal-extent-end'>#{stop}</span></div>" unless stop.nil? or stop.to_str.nil? or stop == ''
      markup += '</div>'
    end
    markup.html_safe
  end

  def render_spatial_extent(bounding_box, polygon, line, point)
    markup = ''
    unless bounding_box.nil? and polygon.nil? and line.nil? and point.nil?
      markup = '<div>'
      markup += "<div class='group-meta'><span>Minimum Bounding Rectangle:</span> <span class='spatial-extent'>#{bounding_box.to_str}</span></div>" unless bounding_box.nil? or bounding_box.to_str.nil?
      markup += "<div class='group-meta'><span>Polygon:</span> <span class='spatial-extent'>#{polygon.to_str}</span></div>" unless polygon.nil? or polygon.to_str.nil?
      markup += "<div class='group-meta'><span>Line:</span> <span class='spatial-extent'>#{line.to_str}</span></div>" unless line.nil? or line.to_str.nil?
      markup += "<div class='group-meta'><span>Point:</span> <span class='spatial-extent'>#{point.to_str}</span></div>" unless point.nil? or point.to_str.nil?
      markup += '</div>'
    end
    markup.html_safe
  end

  def spatial_types
    spatial_types = []
    bb = OpenStruct.new
    bb.id = 'bbox'
    bb.name = 'Bounding box'
    spatial_types << bb

    geometry = OpenStruct.new
    geometry.id = 'geometry'
    geometry.name = 'Geometry'
    spatial_types << geometry

    place_name = OpenStruct.new
    place_name.id = 'placename'
    place_name.name = 'Place Name'
    spatial_types << place_name

    spatial_types
  end

  def boolean_types
    boolean_types = []

    either = OpenStruct.new
    either.id = nil
    either.name = 'Either'
    boolean_types << either

    yes = OpenStruct.new
    yes.id = 'true'
    yes.name = 'Yes'
    boolean_types << yes

    no = OpenStruct.new
    no.id = 'false'
    no.name = 'No'
    boolean_types << no

    boolean_types
  end

  def true_only_types
      boolean_types = []

      either = OpenStruct.new
      either.id = nil
      either.name = 'Don\'t care'
      boolean_types << either

      yes = OpenStruct.new
      yes.id = 'true'
      yes.name = 'Yes'
      boolean_types << yes
    end
end
