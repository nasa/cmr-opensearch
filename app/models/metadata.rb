require 'rgeo'
require 'geo_ruby'

class Metadata

  CLIENT_ID = 'cmr-open-search'

  DOCUMENTATION_MIME_TYPES = %w(text/rtf text/richtext text/plain text/html text/example text/enriched text/directory text/csv text/css text/calendar application/http application/msword application/rtf application/wordperfect5.1)
  DOCUMENTATION_EXTENSIONS = %w(rtf html csv css calendar doc)

  NEW_REL_MAPPING = {:data => 'enclosure',
                     :browse => 'icon',
                     :metadata => 'via',
                     :documentation => 'describedBy',
                     :osdd => 'search',
                     :search => 'search'}

  OLD_REL_MAPPING = {:data => 'http://esipfed.org/ns/fedsearch/1.1/data#',
                     :browse => 'http://esipfed.org/ns/fedsearch/1.1/browse#',
                     :metadata => 'http://esipfed.org/ns/fedsearch/1.1/metadata#',
                     :documentation => 'http://esipfed.org/ns/fedsearch/1.1/documentation#',
                     :osdd => 'search',
                     :search => 'http://esipfed.org/ns/fedsearch/1.0/search#'}

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :clientId, :keyword, :instrument, :satellite, :startTime, :endTime, :boundingBox, :campaign, :processingLevel, :sensor
  attr_accessor :geometry, :numberOfResults, :cursor, :offset, :shortName, :versionId, :dataCenter, :dataset_id, :provider
  attr_accessor :placeName, :uid, :lat, :lon, :radius

  alias :start_time :startTime
  alias :end_time :endTime
  alias :bounding_box :boundingBox
  alias :processing_level :processingLevel
  alias :number_of_results :numberOfResults
  alias :short_name :shortName
  alias :version_id :versionId
  alias :data_center :dataCenter
  alias :place_name :placeName

  # numberOfResults represents the page_size (max 2000) for both page navigation and offset navigation
  validates :numberOfResults, :numericality => {:only_integer => true, :greater_than => 0, :less_than => 2001}, :allow_blank => true
  validates :cursor, :numericality => {:only_integer => true, :greater_than => 0}, :allow_blank => true
  validates :offset, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_blank => true

  validates :clientId, :format => {:with => /\A[a-zA-Z0-9_\-]+\z/,
                                   :message => 'is invalid, it must be an alpha-numeric string of length greater than or equal to 1, and may contain underscore (_) or dash (-) characters.'}, :allow_blank => true

  validate :temporal_must_be_rfc3339
  validate :geometry_is_point_line_polygon
  validate :bbox_is_valid
  validate :point_radius_is_valid

  validate :place_name_exists

  validate :invalid_params

  def initialize(attributes = {})
    @invalid_param_errors = {}
    attributes.each do |name, value|
      if %w(placeName clientId keyword instrument satellite sensor processingLevel campaign startTime endTime boundingBox lat lon radius geometry placeName numberOfResults cursor offset shortName versionId dataCenter dataset_id uid hasGranules isCwic isGeoss isCeos isEosdis isFedeo parentIdentifier provider).include? name.to_s
        send("#{name}=", value)
      else
        # discard invalid query parameter per CEOS-BP-009B
        attributes.delete(name);
        Rails.logger.info("Discarded unsupported query parameter #{name}=#{value} per CEOS Best Practices 009B")
      end
    end
  end

  def persisted?
    false
  end

  def invalid_params
    @invalid_param_errors.each do |error|
      errors.add(error[0], error[1])
    end
  end

  def place_name_exists
    unless placeName.blank?
      errors.add(:placeName, "#{placeName} cannot be located") if !PlaceNameToPoint.exists?(placeName)
    end
  end

  def temporal_must_be_rfc3339
    begin
      DateTime.rfc3339(startTime) unless startTime.blank?
    rescue
      errors.add(:startTime, "#{startTime} is not a valid rfc3339 date")
    end

    begin
      DateTime.rfc3339(endTime) unless endTime.blank?
    rescue
      errors.add(:endTime, "#{endTime} is not a valid rfc3339 date")
    end
  end

  def geometry_is_point_line_polygon
    unless geometry.blank?
      begin
        factory = RGeo::Cartesian.factory
        g = factory.parse_wkt(geometry)
        point = ::RGeo::Feature::Point.check_type(g)
        line = ::RGeo::Feature::LineString.check_type(g)
        polygon = ::RGeo::Feature::Polygon.check_type(g)
        errors.add(:geometry, "#{geometry} is not supported, please use POINT, LINESTRING or POLYGON") if !point and !line and !polygon
      rescue
        errors.add(:geometry, "#{geometry} is not a valid WKT")
      end
    end
  end

  def bbox_is_valid
    unless boundingBox.blank?
      ordinates = boundingBox.gsub(/\s+/, "").split(',')
      if ordinates.length != 4
        errors.add(:boundingBox, "#{boundingBox} is not a valid boundingBox")
      else
        valid = lon_is_valid(:boundingBox, ordinates[0], boundingBox)
        valid = lat_is_valid(:boundingBox, ordinates[1], boundingBox) if valid
        valid = lon_is_valid(:boundingBox, ordinates[2], boundingBox) if valid
        lat_is_valid(:boundingBox, ordinates[3], boundingBox) if valid
      end
    end
  end

  def point_radius_is_valid
    unless lat.blank? and lon.blank? and radius.blank?
      errors.add(:lat, "cannot be empty for point radius search") if lat.blank?
      errors.add(:lon, "cannot be empty for point radius search") if lon.blank?
      errors.add(:radius, "cannot be empty for point radius search") if radius.blank?
    end
  end

  def lat_is_valid(symbol, lat_string, full)
    valid = true
    lat_float = lat_string.to_f
    if (not ["0", "0.0"].include?(lat_string)) and lat_float == 0
      errors.add(symbol, "#{full} is not a valid #{symbol.to_s}")
      valid = false
    else
      if lat_float < -90 or lat_float > 90
        errors.add(symbol, "#{full} is not a valid #{symbol.to_s}")
        valid = false
      end
    end
    valid
  end

  def lon_is_valid(symbol, lon_string, full)
    valid = true
    lon_float = lon_string.to_f
    #to include non-float representations of 0.0, becuase 0 == 0.0!
    if (not ["0", "0.0"].include?(lon_string)) and lon_float == 0
      errors.add(symbol, "#{full} is not a valid #{symbol.to_s}")
      valid = false
    else
      if lon_float < -180 or lon_float > 180
        errors.add(symbol, "#{full} is not a valid #{symbol.to_s}")
        valid = false
      end
    end
    valid
  end

  def self.hits document
    document.root.xpath('os:totalResults', 'os' => 'http://a9.com/-/spec/opensearch/1.1/').first.to_str.to_i
  end

  def self.create_html_model(entry)
    model = OpenStruct.new
    model.links = []
    entry.children.each do |node|
      model.title = node.content if node.name == 'title'
      model.uid = node.content if node.name == 'id'
      model.start = node.content if node.name == 'start'
      model.stop = node.content if node.name == 'end'
      model.bounding_box = node.content if node.name == 'box'
      model.polygon= node.content if node.name == 'polygon'
      model.line = node.content if node.name == 'line'
      model.point = node.content if node.name == 'point'
      model.mbr = node.content if node.name == 'box'
      model.temporal_extent = node.content if node.name == 'date'
      if node.name == 'link' and node[:type] != 'application/atom+xml' and node[:type] != 'application/opensearchdescription+xml'
        url = OpenStruct.new
        url.href = node[:href]
        url.title = node[:title]
        url.title = "Browse image link" if url.title.nil? and node[:rel] == 'icon'
        url.title = "Data link" if url.title.nil? and node[:rel] == 'enclosure'
        url.title = "Metadata link" if url.title.nil? and node[:rel] == 'describedBy'
        url.title = "Documentation link" if url.title.nil? and node[:rel] == 'describedBy'
        if url.title == 'Product metadata'
          model.canononical_link = url
        else
          model.links << url
        end

      end
    end
    model
  end

  # There is a reason we don't simplify this by using xpath. It is really slow over large result sets. Slow enough to generate user complaints.
  def to_open_search_common (doc, hits, params, resource)
    # Add open search namespace
    doc.root.add_namespace 'os', 'http://a9.com/-/spec/opensearch/1.1/'
    # Add esip namespace
    doc.root.add_namespace 'eo', 'http://a9.com/-/opensearch/extensions/eo/1.0/'
    doc.root.add_namespace 'esipdiscovery', 'http://commons.esipfed.org/ns/discovery/1.2/'
    doc.root.add_namespace 'dc', 'http://purl.org/dc/elements/1.1/'
    doc.root.add_namespace 'georss', 'http://www.georss.org/georss'
    doc.root.add_namespace 'time', 'http://a9.com/-/opensearch/extensions/time/1.0/'
    doc.root.add_namespace 'echo', 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom'
    doc.root.add_namespace 'gml', 'http://www.opengis.net/gml'
    doc.root['esipdiscovery:version'] = '1.2'

    subtitle_node = nil
    first_entry = nil
    doc.root.children.each do |node|
      if node.name == 'id'
        node.content = "#{ENV['opensearch_url']}/#{resource}s.atom"
        add_author(doc, node)
      elsif node.name == 'entry'
        first_entry = node if first_entry.nil?
      end
    end

    first_entry = doc.root.children.last if first_entry.nil?
    # Add subtitle node
    subtitle_node = add_subtitle(doc, first_entry, params)

    link = add_link_as_sibling(doc, subtitle_node, ENV['release_page'], 'text/html', 'describedBy', 'Release Notes')

    # Add query node prior to first entry node
    query_node = add_query_node(doc, link, params)
    # Add the hits, items and cursor elements after the Atom elements
    hits_node = Nokogiri::XML::Node.new 'os:totalResults', doc
    hits_node.content= hits
    query_node.add_next_sibling(hits_node)
    if hits.to_i > 0
      items_node = Nokogiri::XML::Node.new 'os:itemsPerPage', doc
      items_node.content = params[:numberOfResults] || 10
      hits_node.add_next_sibling(items_node)
      nor = params[:numberOfResults].to_i
      # offset overwrites cursor
      if !params[:offset].blank?
        start_index = (params[:offset].to_i + 1).to_s
      else
        cursor = params[:cursor].to_i || 1
        start_index = to_start_index(cursor, nor)
      end
      cursor_node = Nokogiri::XML::Node.new 'os:startIndex', doc
      cursor_node.content = start_index
      items_node.add_next_sibling(cursor_node)
    end
    return doc, subtitle_node
  end

  def to_start_index(cursor, number_of_results)
    cursor*number_of_results + 1 - number_of_results
  end


  def to_cmr_params(params)
    cmr_params = {}

    unless params[:cursor].nil?
      value = params[:cursor]
      value = 1 if value.to_i < 1
      cmr_params[:page_num] = value
    end

    cmr_params[:page_size] = params[:numberOfResults] unless params[:numberOfResults].blank?
    cmr_params[:offset] = params[:offset] unless params[:offset].blank?
    cmr_params[:instrument] = params[:instrument] unless params[:instrument].blank?
    cmr_params[:platform] = params[:satellite] unless params[:satellite].blank?
    cmr_params[:include_facets] = params[:include_facets] unless params[:include_facets].blank?

    cmr_params[:bounding_box] = params[:boundingBox].gsub(/\s+/, "") unless params[:boundingBox].blank?
    cmr_params[:circle] = "#{params[:lon]},#{params[:lat]},#{params[:radius]}" unless params[:lat].blank?

    cmr_params = WellFormedText.add_cmr_param(cmr_params, params[:geometry]) unless params[:geometry].blank?

    unless params[:polygon].blank?
      value = params[:polygon]
      cmr_value = to_lon_lat(value)
      cmr_value = close_polygon (cmr_value)
      cmr_params[:polygon] = cmr_value
    end

    unless params[:line].blank?
      value = params[:line]
      cmr_value = to_lon_lat(value)
      cmr_params[:line] = cmr_value
    end

    unless params[:point].blank?
      value = params[:point]
      cmr_value = to_lon_lat(value)
      cmr_params[:point] = cmr_value
    end

    cmr_params = PlaceNameToPoint.add_cmr_param(cmr_params, params[:placeName]) unless params[:placeName].blank?

    unless params[:startTime].blank? and params[:endTime].blank?
      cmr_params[:temporal] = "#{params[:startTime]},#{params[:endTime]}"
    end



    return cmr_params
  end

  # open search using lat/lon pairs, cmr uses lon/lat, both use closed polygons.
  def to_lon_lat(value)
    ordinates = value.gsub(/\s+/, "").split(',')
    cmr_value=""
    range = 0..ordinates.size
    range.step(2) { |x| cmr_value += "#{ordinates[x+1]},#{ordinates[x]}," }
    # Remove last comma
    while cmr_value.ends_with?(',')
      cmr_value.chomp!(',')
    end
    cmr_value
  end

  # open search uses open polygons, cmr uses closed polygons
  def close_polygon(value)
    ordinates = value.gsub(/\s+/, "").split(',')
    cmr_value = value

    # Grab first two and append
    if ordinates.length > 3
      cmr_value.concat(",#{ordinates[0]},#{ordinates[1]}") unless ordinates[0] == ordinates[ordinates.length - 2] && ordinates[1] == ordinates[ordinates.length - 1]
    end
    cmr_value
  end

  def add_link_as_child(doc, entry, href, type, rel, title=nil)
    link = Nokogiri::XML::Node.new 'link', doc
    link[:href] = href
    link[:hreflang] = 'en-US'
    link[:type] = type
    link[:rel] = rel
    link = fix_rel link

    link[:title] = title unless title.nil?
    entry.add_child(link)
    link
  end

  def add_link_as_sibling(doc, entry, href, type, rel, title=nil)
    link = Nokogiri::XML::Node.new 'link', doc
    link[:href] = href
    link[:hreflang] = 'en-US'
    link[:type] = type
    link[:rel] = rel
    link = fix_rel link

    link[:title] = title unless title.nil?
    entry.add_next_sibling(link)
    link
  end

  def add_dc_temporal_extent(doc, entry, start_time, end_time)
    date = Nokogiri::XML::Node.new 'dc:date', doc
    content = nil
    unless start_time == end_time
      content = "#{start_time}/#{end_time}"
    else
      content = "#{start_time}"
    end
    date.content = content
    entry.add_child(date)
    date
  end

  def fix_rel(link)
    unless link[:rel] == 'enclosure'
      if DOCUMENTATION_MIME_TYPES.include? link[:type] or DOCUMENTATION_EXTENSIONS.include? link[:href].split('.').last
        link[:rel] = NEW_REL_MAPPING[:documentation]
      end

      # Translate link
      link[:rel] = NEW_REL_MAPPING.fetch(OLD_REL_MAPPING.key(link[:rel])) if OLD_REL_MAPPING.value?(link[:rel]) and link[:rel] != NEW_REL_MAPPING[:documentation]
    end
    link
  end

  def add_type(link)
    if link[:type].nil?
      link[:type] = 'application/x-hdfeos' if link[:href].ends_with? '.hdf'
      link[:type] = 'application/xml' if link[:href].ends_with? '.xml'
      link[:type] = 'application/xml' if link[:href].ends_with? '.echo10'
      link[:type] = 'image/png' if link[:href].ends_with? '.png'
      link[:type] = 'image/gif' if link[:href].ends_with? '.gif'
      link[:type] = 'image/jpeg' if link[:href].ends_with? '.jpg'
      link[:type] = 'image/jpeg' if link[:href].ends_with? '.jpeg'
      link[:type] = 'application/pdf' if link[:href].ends_with? '.pdf'
      link[:type] = 'text/html' if link[:href].ends_with? '.html'
      link[:type] = 'text/html' if link[:href].include? '.pl'
    end
    link
  end

  def fix_inherited(link)
    link.attribute('inherited').name = 'echo:inherited'
    link
  end

  def add_query_node(doc, node, params)
    query_node = Nokogiri::XML::Node.new "os:Query", doc
    query_node.add_namespace 'geo', 'http://a9.com/-/opensearch/extensions/geo/1.0/'
    query_node.add_namespace 'time', 'http://a9.com/-/opensearch/extensions/time/1.0/'
    query_node.add_namespace 'echo', 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom'
    node.add_next_sibling(query_node)
    query_node[:role] = 'request'
    query_node['os:searchTerms'] = params[:keyword] unless params[:keyword].nil?
    query_node['echo:dataCenter'] = params[:dataCenter] unless params[:dataCenter].nil?
    query_node['echo:shortName'] = params[:shortName] unless params[:shortName].nil?
    query_node['echo:versionId'] = params[:versionId] unless params[:versionId].nil?
    query_node['echo:instrument'] = params[:instrument] unless params[:instrument].nil?
    query_node['eo:platform'] = params[:satellite] unless params[:satellite].nil?
    query_node['echo:campaign'] = params[:campaign] unless params[:campaign].nil?
    query_node['echo:sensor'] = params[:sensor] unless params[:sensor].nil?
    query_node['echo:processing_level'] = params[:processingLevel] unless params[:processingLevel].nil?
    query_node['geo:box'] = params[:boundingBox] unless params[:boundingBox].nil?
    query_node['geo:geometry'] = params[:geometry] unless params[:geometry].nil?
    #query_node['geo:geometry'] = params[:line] unless params[:line].nil?
    #query_node['geo:geometry'] = params[:point] unless params[:point].nil?
    query_node['time:start'] = params[:startTime] unless params[:startTime].nil?
    query_node['time:end'] = params[:endTime] unless params[:endTime].nil?

    query_node['geo:uid'] = params[:uid] unless params[:uid].nil?
    # per OGC OpenSearch RELAX NG ATOM response schema, we cannot add fixed parameters to the request os:Query element
    #query_node['clientId'] = params[:clientId] unless params[:clientId].nil?
    query_node
  end

  def add_subtitle(doc, node, params)
    subtitle = Nokogiri::XML::Node.new 'subtitle', doc
    subtitle[:type] = 'text'

    if doc.xpath('/atom:feed/atom:entry', 'atom' => 'http://www.w3.org/2005/Atom').length == 0
      subtitle.content = "Your search yielded zero matches"
    else
      subtitle.content = "Search parameters:"
      subtitle.content += " keyword => #{params[:keyword]}" unless params[:keyword].nil?
      subtitle.content += " shortName => #{params[:shortName]}" unless params[:shortName].nil?
      subtitle.content += " versionId => #{params[:versionId]}" unless params[:versionId].nil?
      subtitle.content += " dataCenter => #{params[:dataCenter]}" unless params[:dataCenter].nil?
      subtitle.content += " instrument => #{params[:instrument]}" unless params[:instrument].nil?
      subtitle.content += " satellite => #{params[:satellite]}" unless params[:satellite].nil?
      subtitle.content += " campaign => #{params[:campaign]}" unless params[:campaign].nil?
      subtitle.content += " sensor => #{params[:sensor]}" unless params[:sensor].nil?
      subtitle.content += " processingLevel => #{params[:processingLevel]}" unless params[:processingLevel].nil?
      subtitle.content += " boundingBox => #{params[:boundingBox]}" unless params[:boundingBox].nil?
      subtitle.content += " geometry => #{params[:geometry]}" unless params[:geometry].nil?
      subtitle.content += " placeName => #{params[:placeName]}" unless params[:placeName].nil?
      subtitle.content += " startTime => #{params[:startTime]}" unless params[:startTime].nil?
      subtitle.content += " endTime => #{params[:endTime]}" unless params[:endTime].nil?
      subtitle.content += " uid => #{params[:uid]}" unless params[:uid].nil?

      subtitle.content += ' None' if subtitle.content == 'Search parameters:'
    end
    node.before(subtitle)

    subtitle
  end

  def add_author(doc, node)
    author_node = Nokogiri::XML::Node.new "author", doc
    name_node = Nokogiri::XML::Node.new "name", doc
    name_node.content = 'CMR'
    email_node = Nokogiri::XML::Node.new "email", doc
    email_node.content = "#{ENV['contact']}"
    author_node.add_child(name_node)
    author_node.add_child(email_node)
    node.add_next_sibling(author_node)
    node
  end

  def add_dc_identifier(doc, id, parent)
    dc_identifier_node = Nokogiri::XML::Node.new 'dc:identifier', doc
    dc_identifier_node.content = id
    parent.add_child(dc_identifier_node)
    parent
  end

  def add_common_summary(doc, entry, summary)

    # Using xpath is a resource hog for large results set, hence the mess below
    start_time, end_time, bbox, polygon, line, point = nil

    entry.children.each do |node|
      start_time = node.inner_text if node.name == 'start'
      end_time = node.inner_text if node.name == 'end'
      bbox = node.inner_text if node.name == 'box'
      polygon = node.inner_text if node.name == 'polygon'
      line = node.inner_text if node.name == 'line'
      point = node.inner_text if node.name == 'point'
    end

    unless start_time.blank? and end_time.blank?
      summary += "<p><b>Temporal Extent</b></p>"
      summary += "<p><b>Start Time: </b>#{start_time}" unless start_time.blank?
      summary += "<p><b>End Time: </b>#{end_time}" unless end_time.blank?
    end

    if !polygon.blank?
      spatial_exent_for_summary = "<b>Polygon: </b>#{polygon}"
    elsif !line.blank?
      spatial_exent_for_summary = "<b>Line: </b>#{line}"
    elsif !point.blank?
      spatial_exent_for_summary = "<b>Point: </b>#{point}"
    elsif !bbox.blank?
      spatial_exent_for_summary = "<b>Bounding Box: </b>#{bbox}"
    end

    summary += "<p><b>Spatial Extent</b></p>#{spatial_exent_for_summary}" unless spatial_exent_for_summary.blank?
    summary_element = Nokogiri::XML::Node.new "summary", doc
    summary_element.content = summary
    summary_element[:type] ="html"
    summary_element
  end

  def add_nav_links(doc, sibling, hits, params, url)
    if !params[:offset].blank?
      add_offset_nav_links(doc, sibling, hits, params, url)
    else
      add_cursor_nav_links(doc, sibling, hits, params, url)
    end
  end

  # navigation via offset (os:startIndex), CMR offset and CMR OpenSearch offset are 0-based
  def add_offset_nav_links(doc, sibling, hits, params, url)
    url.gsub!('datasets?', 'collections?')
    search_link = add_link_as_sibling(doc, sibling, url, 'application/atom+xml', 'self')

    # Remove offset parameter from url string if present
    remove_url_query_parameter(params, url, 'offset')

    page_size = (number_of_results || params[:numberOfResults]).to_i

    if(hits > 0 )
      # Insert first link for offset navigation, always present as offset 0 if we have hits
      first_link_possible = params[:offset].to_i - page_size
      first_link_offset = first_link_possible % page_size
      if url.include?('?')
        first_url = url + (first_link_possible >= 0 ? "&offset=#{first_link_offset}" : "&offset=#{params[:offset]}")
      else
        first_url = url + (first_link_possible >= 0 ? "?offset=#{first_link_offset}" : "?offset=#{params[:offset]}")
      end
      add_link_as_sibling(doc, search_link, first_url, 'application/atom+xml', 'first')

      # Insert last link - calculate last offset
      elements_from_offset_to_last = hits - params[:offset].to_i
      pages_from_offset_to_last = elements_from_offset_to_last / page_size
      last_offset =  params[:offset].to_i + pages_from_offset_to_last*page_size unless page_size.nil?

      if url.include?('?')
        last_url = url + "&offset=#{last_offset}"
      else
        last_url = url + "?offset=#{last_offset}"
      end
      last_link = add_link_as_sibling(doc, search_link, last_url, 'application/atom+xml', 'last')

      # Insert next link
      if need_next_offset?(params, hits)
        next_offset = params[:offset].to_i + page_size
        if url.include?('?')
          next_url = url + "&offset=#{next_offset}"
        else
          next_url = url + "?offset=#{next_offset}"
        end
        add_link_as_sibling(doc, last_link, next_url, 'application/atom+xml', 'next')
      end

      # Insert previous link
      if need_prev_offset?(params, hits)
        previous_offset = params[:offset].to_i - page_size
        if url.include?('?')
          previous_url = url + "&offset=#{previous_offset}"
        else
          previous_url = url + "?offset=#{previous_offset}"
        end
        add_link_as_sibling(doc, last_link, previous_url, 'application/atom+xml', 'previous')
      end
    end
  end

  # support cursor (os:startPage) pagination
  def add_cursor_nav_links(doc, sibling, hits, params, url)
    url.gsub!('datasets?', 'collections?')
    search_link = add_link_as_sibling(doc, sibling, url, 'application/atom+xml', 'self')

    # Remove cursor query parameter if present
    remove_url_query_parameter(params, url, 'cursor')

    # Insert first link for cursor navigation
    if url.include?('?')
      first_url = url + '&cursor=1'
    else
      first_url = url + '?cursor=1'
    end
    add_link_as_sibling(doc, search_link, first_url, 'application/atom+xml', 'first')

    # Insert last link - calculate last cursor
    nor = number_of_results || params[:numberOfResults]
    last_cursor = hits/nor.to_i + 1 unless nor.nil?
    last_cursor = 1 if nor.nil? || last_cursor < 1
    if url.include?('?')
      last_url = url + "&cursor=#{last_cursor}"
    else
      last_url = url + "?cursor=#{last_cursor}"
    end
    last_link = add_link_as_sibling(doc, search_link, last_url, 'application/atom+xml', 'last')

    # Insert next link
    if need_next_cursor?(params, hits)
      next_cursor = params[:cursor].to_i + 1
      if url.include?('?')
        next_url = url + "&cursor=#{next_cursor}"
      else
        next_url = url + "?cursor=#{next_cursor}"
      end
      add_link_as_sibling(doc, last_link, next_url, 'application/atom+xml', 'next')
    end

    # Insert previous link
    if need_prev_cursor?(params)
      previous_cursor = params[:cursor].to_i - 1
      if url.include?('?')
        previous_url = url + "&cursor=#{previous_cursor}"
      else
        previous_url = url + "?cursor=#{previous_cursor}"
      end
      add_link_as_sibling(doc, last_link, previous_url, 'application/atom+xml', 'previous')
    end
  end

  def generate_mbr(doc, element)
    geometry = element.content
    mbr = Nokogiri::XML::Node.new "georss:box", doc
    bbox = nil
    points = string_to_points geometry
    if element.name == 'georss:polygon'
      bbox = GeoRuby::SimpleFeatures::Polygon.from_points([points]).bounding_box
    elsif element.name == 'georss:line'
      bbox = GeoRuby::SimpleFeatures::LineString.from_points(points).bounding_box
    elsif element.name == 'georss:point'
      bbox = [points[0], points[0]]
    end

    south = bbox[0].y
    east = bbox[1].x
    north = bbox[1].y
    west = bbox[0].x
    mbr.content = "#{south} #{west} #{north} #{east}"

    mbr
  end

  def string_to_points str
    # lat, lng
    points = []
    point_array = str.split(' ')
    point_array.each_index do |x|
      points << GeoRuby::SimpleFeatures::Point.from_x_y(point_array[x+1].to_f, point_array[x].to_f) if x.even?
    end
    points
  end

  def fix_geo_href(response)
    doc_as_string = response.to_str
    doc_as_string.gsub!('http://www.georss.org/georss/10', 'http://www.georss.org/georss')
    doc_as_string
  end

  def need_prev_cursor? (params)
    params[:cursor].to_i > 1
  end

  def need_prev_offset? (params, hits)
    # offset always starts at the desired offset, pagination always starts at 1
    # consider that we can decrease the offset by the page_size as long as we are within the result bounds
    offset = params[:offset].to_i
    page_size = params[:numberOfResults].to_i
    offset -  page_size >= 0
  end

  def need_next_cursor? (params, hits)
    cursor = params[:cursor].to_i
    cursor = cursor - 1 unless cursor == 0
    hits > (cursor*params[:numberOfResults].to_i + params[:numberOfResults].to_i)
  end

  def need_next_offset? (params, hits)
    offset = params[:offset].to_i
    #offset =  offset -1 unless offset = 0
    page_size = params[:numberOfResults].to_i
    hits - offset >= page_size
  end

  private

  def remove_url_query_parameter(params, url, param_name)
    url.gsub!("#{param_name}=\&", '')
    url.gsub!("#{param_name}=#{params[param_name.to_sym]}\&", '')
    url.gsub!("#{param_name}=#{params[param_name.to_sym]}", '')
    url.gsub!("#{param_name}=", '')
    url.chop! if url.end_with?('&')
  end
end
