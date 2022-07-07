require 'securerandom'

module GranulesHelper
  QUERY = <<~GRAPH_QUERY.freeze
    query OpenSearchCollection(
      $conceptId: String!
    ) {
      collection (params: {
        conceptId: $conceptId,
        includeTags: "opensearch.granule.osdd, org.ceos.wgiss.cwic.granules.provider, org.ceos.wgiss.cwic.granules.native_id"
      }) {
        conceptId
        relatedUrls
        spatialExtent
        tags
        temporalExtents
      }
    }
  GRAPH_QUERY

  # query_graphql
  #
  # @param [Hash] params Search parameters
  # @param [String] request_id A GUID to send GraphQL for logging
  #
  # @return [RestClient::Response] Response from GraphQL
  def query_graphql(params, request_id)
    url = Rails.configuration.graphql_endpoint

    RestClient::Request.execute(
      method: :post,
      url: url,
      headers: {
        accept: :json,
        content_type: :json,
        'Client-Id': "opensearch-#{Rails.env.downcase}-client",
        'X-Request-Id': request_id
      },
      payload: {
        query: QUERY,
        variables: params
      }.to_json
    )
  rescue StandardError => e
    puts("#{request_id} - Error - Failed to retrieve collection descriptor for (#{url}) with message #{e.message}.")
  end

  # determine_granule_url
  #
  # @param [Hash] metadata The metadata response from a graphql query
  #
  # @return [String] The url found within a designated locations within the metadata
  def determine_granule_url(collection)
    url = determine_granule_url_by_related_url(collection)

    return url if url.present?

    determine_granule_url_by_tags(collection)
  end

  # determine_granule_url_by_tags
  #
  # @param [Hash] metadata The metadata response from a graphql query
  #
  # @return [String] The url found within a correctly utilized related url object
  def determine_granule_url_by_related_url(collection)
    return if collection.fetch('relatedUrls', []).blank?

    related_urls = collection.fetch('relatedUrls', []).select { |url| (url['urlContentType'] && url['urlContentType'] == 'DistributionURL') && (url['subtype'] && url['subtype'] == 'OpenSearch') }

    # Return a url if one was found within the related urls
    return related_urls.first['url'] unless related_urls.blank?
  end

  # determine_granule_url_by_tags
  #
  # @param [Hash] metadata The metadata response from a graphql query
  #
  # @return [String] The value from the tag that defines an opensearch osdd
  def determine_granule_url_by_tags(collection)
    # Otherwise return the tag data (defaulting to nil via `dig`)
    collection.dig('tags', 'opensearch.granule.osdd', 'data')
  end

  # determine_provider_by_tag
  #
  # @param [Hash] metadata The metadata response from a graphql query
  #
  # @return [String] The value from the tag that defines an opensearch provider
  def determine_provider_by_tag(metadata)
    return if metadata.nil? || metadata['tags'].nil?

    metadata.fetch('tags', {}).fetch('org.ceos.wgiss.cwic.granules.provider', {}).fetch('data', {})
  end

  # determine_native_id_by_tag
  #
  # @param [Hash] metadata The metadata response from a graphql query
  #
  # @return [String] The value from the tag that defines an opensearch native id
  def determine_native_id_by_tag(metadata)
    return if metadata.nil? || metadata['tags'].nil?

    metadata.fetch('tags', {}).fetch('org.ceos.wgiss.cwic.granules.native_id', {}).fetch('data', {})
  end

  # build_spatial
  #
  # @param [Hash] metadata The metadata response from a graphql query
  #
  # @return [Array] An array of spatial coordinates
  def build_spatial(metadata)
    spatial_list = []

    return spatial_list if metadata.nil?

    horizontal_spatial_domain = metadata.fetch('horizontalSpatialDomain', {})

    if horizontal_spatial_domain
      geometry = horizontal_spatial_domain.fetch('geometry', {})

      if geometry.key?('boundingRectangles')
        boxes = Array(geometry.fetch('boundingRectangles', []))

        boxes.each do |box|
          north = box['northBoundingCoordinate']
          south = box['southBoundingCoordinate']
          east = box['eastBoundingCoordinate']
          west = box['westBoundingCoordinate']

          spatial_list.push("#{west},#{south},#{east},#{north}")
        end
      end

      # TODO: Ideally we can support a minimum bounding rectangle for polygons and lines in the future but
      # at the moment. When we can determine how to set min/max values for spatial we should add support
      # for these types as well

      # if geometry.has_key?('gPolygons')
      #   polygons = Array(gPolygons)

      #   let string = 'Polygon: ('

      #   polygons.forEach((polygon) => {
      #     points = Array(polygon.boundary.points)

      #     points.forEach((point, i) => {
      #       { latitude, longitude } = point

      #       string += `(${latitude}, ${longitude})${i + 1 < points.length ? ', ' : ''}`
      #     })

      #     string += ')'

      #     spatial_list.push(string)
      #   })
      # end

      # if geometry.has_key?('lines')
      #   castedLines = Array(lines)

      #   castedLines.forEach((line) => {
      #     latitude1 = line.points[0].latitude
      #     longitude1 = line.points[0].longitude
      #     latitude2 = line.points[1].latitude
      #     longitude2 = line.points[1].longitude

      #     spatial_list.push(`Line: ((${latitude1}, ${longitude1}), (${latitude2}, ${longitude2}))`)
      #   })
      # end
    end

    spatial_list
  end

  # build_temporal
  #
  # @param [Hash] metadata The metadata response from a graphql query
  #
  # @return [Array] An array of spatial coordinates
  def build_temporal(metadata)
    single_date_times = metadata.fetch('singleDataTimes', [])

    # Single date times are found on the SingleDateTime key
    if single_date_times
      ends_at_present_flag = metadata.fetch('endsAtPresentFlag', false)

      single_date_times.each do |date_time|
        date = Time.parse(date_time).utc.iso8601

        # ends_at_present_flag suggests that there is no end time, it ends at
        # whatever 'present day' is considered, if that is the case we just add a year
        # to today to represent this, otherwise the range ends today.
        ends_at_present_flag ? [date, DateTime.now.next_year] : [date, DateTime.now]
      end
    end

    range_date_times = metadata.fetch('rangeDateTimes', [])

    # If were not dealing with a SingleDateTime, the metadata should have range_date_times
    if range_date_times.is_a?(Array)
      range_date_times.map do |range|
        beginning_date_time = range['beginningDateTime']
        ending_date_time = range['endingDateTime']

        # If ends_at_present_flag is set, or endingDate time is missing, we know this is
        # an 'ongoing' date which we represent by adding 1 year to today to ensure a range
        # exists when populating the template
        if ends_at_present_flag || ending_date_time.nil?
          return [Time.parse(beginning_date_time).iso8601, Time.now.next_year.utc.iso8601]
        end

        # Otherwise, we know that this is a range
        return [Time.parse(beginning_date_time).iso8601, Time.parse(ending_date_time).iso8601]
      end
    end

    # If its neither a SingleDateTime or rangeDateTimes is not set, the
    # entry is not valid and we return an array representing the beginning
    # of time to this day next year
    [DateTime.parse('1970-01-01T00:00:00Z'), Time.now.next_year.utc.iso8601]
  end

  # fetch_opensearch_data
  #
  # @param [String] concept_id The concept id of the collection being requested
  #
  # @return [Hash] Mapping of data required to generate a descriptor document
  def fetch_opensearch_data(concept_id)
    # Create a GUID that we include in each of our logs and send to GraphQL to better match requests
    logging_request_id = SecureRandom.uuid

    # Query GraphQL
    graphql_response = query_graphql({ conceptId: concept_id }, logging_request_id)

    parsed_response = JSON.parse(graphql_response)

    errors = parsed_response.fetch('errors', [])

    # If any errors are returned return the error template
    unless errors.blank?
      return {
        'error' => errors[0].fetch('message'),
        'erb_file' => 'error.xml.erb'
      }
    end

    collection_metadata = parsed_response.fetch('data', {}).fetch('collection', {})

    # If no errors are retured but no metadata is returned either, the collection doesn't exist
    if collection_metadata.nil?
      return {
        'error' => "Collection with id #{concept_id} not found.",
        'erb_file' => 'error.xml.erb'
      }
    end

    # Pull out the provider to determine which tempalte to render
    provider = determine_provider_by_tag(collection_metadata)

    unless provider.present?
      return {
        'error' => 'No provider present within the `org.ceos.wgiss.cwic.granules.provider` tag.',
        'erb_file' => 'error.xml.erb'
      }
    end

    # Pull out the native id to provide to the osdd for collection identification
    native_id_by_tag = determine_native_id_by_tag(collection_metadata)

    unless native_id_by_tag.present?
      return {
        'error' => 'No native id present within the `org.ceos.wgiss.cwic.granules.native_id` tag.',
        'erb_file' => 'error.xml.erb'
      }
    end

    temporal = build_temporal(collection_metadata.fetch('temporalExtents', []).first)

    spatial = build_spatial(collection_metadata.fetch('spatialExtent', {})).first

    if provider == 'NASA'
      {
        'erb_file' => 'descriptor_document.xml.erb'
      }
    else
      {
        'begin' => temporal[0],
        'dataset_id' => native_id_by_tag,
        'end' => temporal[1],
        'geo_box' => spatial,
        'erb_file' => "#{provider.downcase}.xml.erb"
      }
    end
  end
end
