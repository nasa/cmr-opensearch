class Granule < Metadata

  # this is the collection conceptId
  attr_accessor :parentIdentifier
  alias :parent_identifier :parentIdentifier
  # this indicates whether or not the granule search is the result of a the search form submission
  attr_accessor :invokedFromSearchForm

  validate :form_submission_required_params

  def find(params, url)
    cmr_params = to_cmr_granule_params(params)
    Rails.logger.info "CMR Params: #{cmr_params}"
    response = nil
    query_url = "#{ENV['catalog_rest_endpoint']}granules.atom"
    Rails.logger.info "RestClient call to CMR endpoint: #{query_url}?#{cmr_params.to_query}"
    time = Benchmark.realtime do
      response = RestClient::Request.execute :method => :get, :url => query_url, :verify_ssl => OpenSSL::SSL::VERIFY_NONE, :headers => {:client_id => CLIENT_ID, :params => cmr_params}
    end
    Rails.logger.info "CMR granule search took #{(time.to_f * 1000).round(0)} ms"
    hits = response.headers[:cmr_hits] ? response.headers[:cmr_hits].to_i : 0
    results = nil
    elapsed_time = Benchmark.realtime do
      # ruby plus nokogiri do not let us overwrite namespace hrefs so we have to do it at the string level
      doc_as_string = fix_geo_href(response)
      results = to_open_search_granules(Nokogiri::XML(doc_as_string), hits, params, url)
    end
    Rails.logger.info "Open Search translation took : #{(elapsed_time.to_f * 1000).round(0)} ms"
    results
  end

  # There is a reason we don't simplify this by using xpath. It is really slow over large result sets. Slow enough to generate user complaints.
  def to_open_search_granules(doc, hits, params, url)
    doc, subtitle_node = to_open_search_common(doc, hits, params, 'granule')
    add_nav_links(doc, subtitle_node, hits, params, url)
    add_esipbp_uplink(doc, subtitle_node, url)
    doc.root.children.each do |node|
      if node.name == 'entry'
        id_node, last_link, start_time, end_time, mbr = nil
        non_atom = []
        # if/elsif is faster than case.
        node.children.each do |sub_node|
          if sub_node.name == 'title'
            sub_node[:type] = 'text' if sub_node.element?
          elsif sub_node.name == 'link'
            # resolve the ambiguous CMR #data ( OpenSearch enclosure) links which in some cases result in more than one
            # enclosure link but only one valid link for the actual data retrieval
            if sub_node['rel'].end_with?('/data#') && sub_node.at_xpath('echo:inherited', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')
              # the 'GET DATA' link should bot be there in the first place, it is inherited from the collection and does
              # not allow direct access to the granule data file
              sub_node.remove
            else
              decorate_link(node, sub_node)
              last_link = sub_node
            end
          elsif sub_node.name == 'id'
            id_node = sub_node
          elsif sub_node.name == 'start'
            start_time = sub_node.content
          elsif sub_node.name == 'end'
            end_time = sub_node.content
          elsif sub_node.name == 'georss:polygon' or sub_node.name == 'georss:line' or sub_node.name == 'georss:point'
            mbr = generate_mbr(doc, sub_node)
          end
          non_atom << sub_node.remove if sub_node.namespace.nil? or sub_node.namespace.href != 'http://www.w3.org/2005/Atom'
        end

        last_link = doc.root.children.last if last_link.nil?
        guid = id_node.content
        id_node.content = "#{ENV['opensearch_url']}/granules.atom?uid=#{guid}"
        add_cmr_metadata_link(doc, last_link, node, guid)
        add_dc_identifier(doc, guid, node)
        add_dc_temporal_extent(doc, node, start_time, end_time) unless start_time.nil? and end_time.nil?
        # Add non-atom element array
        non_atom.each do |element|
          node.add_child(element)
        end
        node.add_child(mbr) unless mbr.nil?
      end
    end
    doc.xpath('//echo:onlineAccessFlag', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').remove
    doc.xpath('//echo:browseFlag', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').remove
    doc.xpath('//echo:dayNightFlag', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').remove
    doc.xpath('//time:start', 'time' => 'http://a9.com/-/opensearch/extensions/time/1.0/').remove
    doc.xpath('//time:end', 'time' => 'http://a9.com/-/opensearch/extensions/time/1.0/').remove
    opensearch_doc = Nokogiri::XML(doc.to_xml) do |config|
      config.default_xml.noblanks
    end

    opensearch_doc
  end

  def add_cmr_metadata_link(doc, last_link, entry, guid)
    link = Nokogiri::XML::Node.new 'link', doc
    link[:href] = "#{ENV['public_catalog_rest_endpoint']}concepts/#{guid}.xml"
    link[:hreflang] = 'en-US'
    link[:type] = 'application/xml'
    link[:rel] = 'via'
    link = fix_rel link

    link[:title] = 'Product metadata'
    # Add as sibling to last link element in entry
    if last_link.nil?
      entry.add_child(link)
    else
      last_link.add_next_sibling(link)
    end

  end

  def decorate_link(node, sub_node)
    sub_node = add_type(sub_node)
    # Replace rel if this is documentation
    sub_node = fix_rel(sub_node)
    # Namespace inherited attribute if present
    sub_node = fix_inherited(sub_node) unless sub_node[:inherited].nil?
    #node.add_child(sub_node)
    sub_node
  end

  # There is a reason we don't simplify this by using xpath. It is really slow over large result sets. Slow enough to generate user complaints.
  def self.to_html_model granules_document
    granules = []
    granules_document.root.children.each do |node|
      if node.name == 'entry'
        granule = create_html_model(node)
        granules << granule
      end
    end
    granules
  end

  def add_granule_summary(doc, entry)
    dataset_id = nil
    entry.children.each do |node|
      dataset_id = node.content if node.name == 'datasetId'
    end
    summary = "<p><b>Dataset ID: </b>#{dataset_id}</p>"
    summary_element = add_common_summary(doc, entry, summary)
    entry.add_child(summary_element)
  end

  def to_cmr_granule_params params
    cmr_granule_params = {}
    cmr_granule_params[:short_name] = params[:shortName] unless params[:shortName].blank?
    cmr_granule_params[:version] = params[:versionId] unless params[:versionId].blank?
    cmr_granule_params[:provider] = params[:dataCenter] unless params[:dataCenter].blank?
    cmr_granule_params[:echo_granule_id] = params[:uid] unless params[:uid].blank?
    cmr_granule_params[:dataset_id] = params[:dataset_id] unless params[:dataset_id].blank?
    cmr_granule_params[:collection_concept_id] = params[:parentIdentifier] unless params[:parentIdentifier].blank?

    cmr_params = to_cmr_params(params)
    cmr_granule_params.merge! cmr_params
    cmr_granule_params
  end

  def form_submission_required_params
    if invokedFromSearchForm && uid.blank? && parentIdentifier.blank? && shortName.blank?
      if shortName.blank?
        errors.add(:shortName, ": A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier")
      end
      if parentIdentifier.blank?
        errors.add(:parentIdentifier, ": A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier")
      end
      if uid.blank?
        errors.add(:uid, ": A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier")
      end

    end
  end

  private

  # we only need an uplink if ALL the granules in the current granule search response have the same datasetId
  def add_esipbp_uplink(doc, subtitle_node, url)
    up_link = nil
    dataset_ids_hash = Hash.new
    echo_datasetid_nodes = doc.xpath('//echo:datasetId', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')
    # can only add the up link per ESIP BP spec if ALL the granules in the result have the same datasetId
    echo_datasetid_nodes.each do |echo_datasetid_node|
      dataset_ids_hash[echo_datasetid_node.text] = nil
    end
    if dataset_ids_hash.size == 1
      url = url.gsub(/\?.*/, "?datasetId=#{dataset_ids_hash.keys[0]}")
      up_link = add_link_as_sibling(doc, subtitle_node, url, 'application/atom+xml', 'up')
    end
    return up_link
  end

end
