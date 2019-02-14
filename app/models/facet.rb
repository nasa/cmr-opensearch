class Facet
  # At the moment we only support searching by some of the supported facets. When we add additional search parameters
  # we can uncomment the additional facets below
  FACET_MAPPING = {
      'platform' => 'Satellite',
      'instrument' => 'Instrument',
      'project' => 'Campaign',
      'sensor' => 'Sensor',
      'processing_level_id' => 'Processing Level'
      # 'two_d_coordinate_system_name' => 'Two Dimensional Coordinate Name',
      # 'category' => 'Category Keyword',
      # 'topic' => 'Topic Keyword',
      # 'term' => 'Term Keyword',
      # 'variable_level_1' =>'Variable Level 1 Keyword',
      # 'variable_level_2' =>'Variable Level 2 Keyword',
      # 'variable_level_3' =>'Variable Level 3 Keyword',
      # 'detailed_variable' =>'Detailed Variable',
  }

  def self.extract_facet_params params
    facet_params = {}
    facet_params[:facet_limit] = params[:facetLimit] unless params[:facetLimit].blank?
    facet_params[:facet_start] = params[:facetStart] unless params[:facetStart].blank?
    facet_params[:facet_sort] = params[:facetSort] unless params[:facetSort].blank?
    facet_params[:facet_count] = params[:facetCount] unless params[:facetCount].blank?
    facet_params
  end

  def self.whole_list?(params)
    !params[:facet_limit].blank? and params[:facet_limit] == '-1'
  end

  def self.process_facet_search(collections, facet_params)
    cmr_facets = collections.xpath('//echo:facets', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')
    opensearch_facets, facet_count = to_opensearch_facets(cmr_facets)
    # for now we only support the facetLimit
    if (facet_params[:facet_limit].to_i > 0)
      # enforce a non zero positive limit
      processed_facet_response = enforce_positive_facet_limit(opensearch_facets, facet_params[:facet_limit].to_i)
    else
      processed_facet_response = opensearch_facets
    end
    # remove cmr facets and replace with sru facets
    cmr_facets.remove
    collections.root.add_child(processed_facet_response) unless processed_facet_response.nil?
    return processed_facet_response, facet_count
  end


  # the positive facet limit is used to enforce the maximum number of counts reported per facet field
  # for each field, reduce amount to 100 and reduce individual actualTerm counts by the same pecentage as the field (aggregate)
  def self.enforce_positive_facet_limit(opensearch_original_facet_response, positive_facet_limit)
    global_facet_limit_response = opensearch_original_facet_response
    facet_nodes = opensearch_original_facet_response.xpath('.//sru:facets/sru:facet', 'sru' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
    facet_nodes.each do |facet|
      # we traverse each facet because we'll also have to support individual facet limits
      facet_term_count_nodes = facet.xpath('.//sru:terms/sru:term/sru:count', 'sru' => 'http://docs.oasis-open.org/ns/search-ws/facetedResults')
      facet_term_count_nodes.each do |count|
        if (count.content.to_i > positive_facet_limit)
          count.content=(positive_facet_limit.to_s)
        end
      end
    end
    return global_facet_limit_response
  end

  # processing for ALL supported request facet parameters
  def self.processing_required(params)
    processing_required = false;
    Rails.logger.info "Facet parameters: #{params.inspect}"
    facet_limit = params[:facet_limit]
    if !facet_limit.blank?
      case facet_limit.to_i
        when Integer
          case facet_limit
            when '0'
              Rails.logger.info "Facet processing not requested due to faceLimit value: #{facet_limit}"
            when '-1'
              # stop processing ALL other facet parameters and present ALL facets matching the query string
              processing_required = true
              Rails.logger.info "All facet values will be returned and all other facet parameter values discarded due to facetLimit value: #{facet_limit}"
              # remove ALL other params except for facetLimit = -1
              params.replace({:facet_limit => '-1'})
              return [processing_required]
            else
              processing_required = true
              Rails.logger.info "Result set processing required due to facetLimit value: #{facet_limit}"
          end
        else
          Rails.logger.info "Unsupported faceLimit value: #{facet_limit}"
      end
    else
      Rails.logger.info "None of the specified facet search parameters: #{params.inspect} are supported in the current implementation"
    end
    return processing_required
  end

  def self.to_opensearch_facets(cmr_response_facet_xml)
    facets = ''
    facet_count = 0
    cmr_response_facet_xml.children.each do |facet|
      real_name = facet['field']
      display_name = FACET_MAPPING["#{real_name}"]
      unless display_name.blank?
        terms = ''
        facet.children.each do |t|
          #unless t.name == 'text'
            term = <<-eos
                         <sru:term>
                           <sru:actualTerm>#{t.text}</sru:actualTerm>
                           <sru:count>#{t['count']}</sru:count>
                         </sru:term>
            eos
            terms << term
          #end
        end
        #unless facet.name == 'text'
          f = <<-eos
                    <sru:facet>
                      <sru:facetDisplayLabel>#{display_name}</sru:facetDisplayLabel>
                    	<sru:index>#{real_name}</sru:index>
                    	<sru:relation>=</sru:relation>
                      <sru:terms>#{terms}</sru:terms>
                    </sru:facet>
          eos
          facets << f
          facet_count = facet_count + 1
        #end
      end
    end

    os_facet_string = <<-eos
      <sru:facetedResults xsi:schemaLocation="http://docs.oasis-open.org/ns/search-ws/facetedResults facetedResults.xsd" xmlns:sru="http://docs.oasis-open.org/ns/search-ws/facetedResults" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      	<sru:datasource>
      		<sru:datasourceDisplayLabel>CMR REST API</sru:datasourceDisplayLabel>
      		<sru:datasourceDescription>CMR catalog holdings exposed via the CMR REST API</sru:datasourceDescription>
      		<sru:baseURL>https://earthdata.nasa.gov/echo</sru:baseURL>
      		<sru:facets>#{facets}</sru:facets>
        </sru:datasource>
      </sru:facetedResults
    eos
    # format the fragment since it will not be formatted when added to the atom feed
    os_facet_doc = Nokogiri::XML(os_facet_string) do |config|
      config.default_xml.noblanks
    end
    return Nokogiri::XML::DocumentFragment.parse(os_facet_doc.root), facet_count
  end

end
