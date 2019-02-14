class Collection < Metadata

  attr_accessor :cmr_params
  attr_accessor :hasGranules, :isCwic, :isGeoss, :isEosdis, :isCeos

  def find(params, url, for_atom = true, cwic_testing = false)
    collections = []
    @cmr_params = to_cmr_collection_params(params)
    Rails.logger.info "CMR Params: #{cmr_params}"
    response = nil
    time = Benchmark.realtime do
      query_url = "#{ENV['catalog_rest_endpoint']}collections.atom"
      Rails.logger.info "RestClient call to CMR endpoint: #{query_url}?#{cmr_params.to_query}"
      response = RestClient::Request.execute :method => :get, :url => query_url, :verify_ssl => OpenSSL::SSL::VERIFY_NONE, :headers => {:client_id => CLIENT_ID, :params => cmr_params}
    end
    Rails.logger.info "CMR collection search took #{(time.to_f * 1000).round(0)} ms"

    hits = response.headers[:cmr_hits] ? response.headers[:cmr_hits].to_i : 0
    elapsed_time = Benchmark.realtime do
      # ruby plus nokogiri do not let us overwrite namespace hrefs so we have to do it at the string level
      doc_as_string = fix_geo_href(response)
      collections = to_open_search_collections(Nokogiri::XML(doc_as_string), hits, params, url, for_atom, cwic_testing)
    end
    Rails.logger.info "Open Search translation took : #{(elapsed_time.to_f * 1000).round(0)} ms"
    collections
  end

  # There is a reason we don't simplify this by using xpath. It is really slow over large result sets. Slow enough to generate user complaints.
  def self.to_html_model collections_document
    collections = []

    collections_document.root.children.each do |node|
      if node.name == 'entry'
        collection = create_html_model(node)
        collection.has_granules = false
        node.children.each do |sub_node|
          collection.short_name = sub_node.content if sub_node.name == 'shortName'
          collection.version_id = sub_node.content if sub_node.name == 'versionId'
          collection.data_center = sub_node.content if sub_node.name == 'dataCenter'
          collection.description = sub_node.content if sub_node.name == 'summary' and sub_node[:type] == 'text'
          collection.dc_date = sub_node.content if sub_node.name == 'date'
          collection.mbr = sub_node.content if sub_node.name == 'box'
          collection.has_granules = true if sub_node.name == 'hasGranules' && sub_node.content == 'true'
        end
        collections << collection
      end
    end
    collections
  end

  # There is a reason we don't simplify this by using xpath. It is really slow over large result sets. Slow enough to generate user complaints.
  def to_open_search_collections(document, hits, params, url, for_atom = true, cwic_testing = false)
    # Insert granules descriptor document link
    doc, subtitle_node = to_open_search_common(document, hits, params, 'collection')
    granule_osdd_link = add_link_as_sibling(doc, subtitle_node, "#{ ENV['opensearch_url']}/granules/descriptor_document.xml", 'application/opensearchdescription+xml', NEW_REL_MAPPING[:search])
    add_nav_links(doc, granule_osdd_link, hits, params, url)

    doc.root.children.each do |node|
      if node.name == 'title'
        node.content = 'CMR collection metadata' if node.content == 'CMR dataset metadata'
      end
      if node.name == 'entry'
        short_name = nil
        version_id = nil
        data_center = nil
        archive_center = nil
        dif_id = nil
        guid = nil
        start_time = nil
        end_time = nil
        id = nil
        id_node = nil
        mbr = nil
        has_granules = false
        create_cwic_osdd_link = false
        provider_osdd_link = nil
        is_geoss = false
        is_eosdis = false
        # mark the collection as CEOS if needed
        is_ceos = ceos_collection?(node)
        non_atom = []
        node.children.each do |entry_node|

          fix_rel(entry_node) if entry_node.name == 'link'
          add_type(entry_node) if entry_node.name == 'link'

          id_node = entry_node if entry_node.name == 'id'
          # this is the CMR concept-id
          id = entry_node.content if entry_node.name == 'id'

          entry_node[:type] = 'text' if entry_node.name == 'title'
          entry_node.content = 'CMR collection metadata' if entry_node.content == 'CMR dataset metadata'

          short_name = entry_node.content if entry_node.name == 'shortName'
          version_id = entry_node.content if entry_node.name == 'versionId'
          data_center = entry_node.content if entry_node.name == 'dataCenter'
          archive_center = entry_node.content if entry_node.name == 'archiveCenter'
          dif_id = entry_node.content if entry_node.name == 'difId'
          guid = entry_node.content if entry_node.name == 'id'
          entry_node.content = "#{ENV['opensearch_url']}/collections.atom?uid=#{guid}" if entry_node.name == 'id'
          start_time = entry_node.content if entry_node.name == 'start'
          end_time = entry_node.content if entry_node.name == 'end'
          entry_node[:type] = 'text' if entry_node.name == 'summary'
          mbr = generate_mbr(doc, entry_node) if entry_node.name == 'georss:polygon' || entry_node.name == 'georss:line' || entry_node.name == 'georss:point'
          # if node is not an ATOM node then remove it and put it into the array
          non_atom << entry_node.remove if !entry_node.namespace.nil? and entry_node.namespace.href != 'http://www.w3.org/2005/Atom' or entry_node.name.include? 'georss:'
          has_granules = true if entry_node.name == 'hasGranules' && entry_node.content == 'true'
          if entry_node.name == 'tag'
            create_cwic_osdd_link = cwic_collection?(entry_node, cwic_testing) unless create_cwic_osdd_link == true
            provider_osdd_link = provider_granule_osdd_collection_link(entry_node)
            is_geoss = geoss_collection?(entry_node) unless is_geoss == true
            is_eosdis = eosdis_collection?(entry_node) unless is_eosdis == true
          end
        end

        add_author(doc, id_node)
        unless dif_id.blank?
          href = "http://gcmd.nasa.gov/getdif.htm?#{dif_id}"
          add_link_as_child(doc, node, href, 'text/html', 'enclosure', short_name)
        end

        if !provider_osdd_link.nil?
          add_link_as_child(doc, node, "#{provider_osdd_link}", 'application/opensearchdescription+xml', NEW_REL_MAPPING[:search], 'Non-CMR OpenSearch Provider Granule Open Search Descriptor Document')
        elsif create_cwic_osdd_link && !id.blank?
          add_link_as_child(doc, node, "#{Rails.configuration.cwic_granules_osdd_endpoint}opensearch/datasets/#{id}/osdd.xml?clientId=#{params[:clientId]}", 'application/opensearchdescription+xml', NEW_REL_MAPPING[:search], 'CWIC Granule Open Search Descriptor Document')
        elsif has_granules == true
          add_link_as_child(doc, node, "#{ENV['opensearch_url']}/granules.atom?clientId=#{params[:clientId]}&shortName=#{short_name}&versionId=#{version_id}&dataCenter=#{data_center}", 'application/atom+xml', NEW_REL_MAPPING[:search], 'Search for granules')
          add_link_as_child(doc, node, "#{ENV['opensearch_url']}/granules/descriptor_document.xml?clientId=#{params[:clientId]}&shortName=#{short_name}&versionId=#{version_id}&dataCenter=#{data_center}", 'application/opensearchdescription+xml', NEW_REL_MAPPING[:search], 'Custom CMR Granule Open Search Descriptor Document')
        end

        add_link_as_child(doc, node, "#{ENV['public_catalog_rest_endpoint']}concepts/#{guid}.xml", 'application/xml', 'via', 'Product metadata')

        add_dc_identifier(doc, id, node)
        add_dc_temporal_extent(doc, node, start_time, end_time) unless start_time.nil? and end_time.nil?
        # Add non-atom element array
        non_atom.each do |element|
          node.add_child(element)
        end
        add_geoss(doc, node) if is_geoss
        add_ceos(doc, node) if is_ceos
        add_eosdis(doc, node) if is_eosdis
        node.add_child(mbr) unless mbr.nil?
      end
    end

    # Remove all difId, onlineAccessFlag and browseFlag
    doc.xpath('//foo:difId', 'foo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').remove
    doc.xpath('//foo:onlineAccessFlag', 'foo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').remove
    doc.xpath('//foo:browseFlag', 'foo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').remove
    doc.xpath('//time:start', 'time' => 'http://a9.com/-/opensearch/extensions/time/1.0/').remove
    doc.xpath('//time:end', 'time' => 'http://a9.com/-/opensearch/extensions/time/1.0/').remove
    doc.xpath('//foo:originalFormat', 'foo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').remove
    doc.xpath('//foo:hasGranules', 'foo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').remove if for_atom == true
    raw_string = doc.to_xml
    opensearch_doc = Nokogiri::XML(raw_string) do |config|
      config.default_xml.noblanks
    end
    return opensearch_doc
  end

  # a cwic dataset exists and results in a creation of a CWIC OSDD link in the OpenSearch response if the dataset is
  # tagged with namespace = 'org.ceos.wgiss.cwic.granules' | value = 'prod' OR the Cwic-User = test request header is
  # present and dataset is tagged with namespace = 'org.ceos.wgiss.cwic.granules' | value = 'test'
  def cwic_collection?(entry_node, cwic_testing)
    has_prod_cwic = false
    if entry_node.name == 'tag'
      value = ''
      entry_node.children.each do |tag_node|
        value = tag_node.content if tag_node.name == 'tagKey'
      end
      if (value == 'org.ceos.wgiss.cwic.granules.prod' || (value == 'org.ceos.wgiss.cwic.granules.test' && cwic_testing))
        has_prod_cwic = true
      end
    end
    has_prod_cwic
  end

  # a provider granule OSDD collection results in the creation of a provider specific granule OSDD link if the dataset
  # is tagged with the namespace 'opensearch.granule.osdd'.  The OSDD link is retrieved from the tag data value, which
  # represents the collection level, granule specific OSDD
  def provider_granule_osdd_collection_link(entry_node)
    granule_specific_osdd = nil
    if entry_node.name == 'tag'
      tag_key = entry_node.at_xpath('echo:tagKey', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')
      tag_data = entry_node.at_xpath('echo:data', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')
      if (tag_key != nil) && (tag_key.text == Rails.configuration.granule_osdd_tag)
        if tag_data != nil
          # sample node is: <echo:data>"http://cwictest.wgiss.ceos.org/opensearch/datasets/C1239566345-EUMETSAT/osdd.xml?clientId=rspec13"</echo:data>
          granule_specific_osdd = tag_data.text.delete('"')
        end
      end
    end
    granule_specific_osdd
  end

  # a geoss collection exists and results in a creation of a echo:is_geoss element with value 'true' if the collection
  # is tagged with namespace = 'org.geo.geoss_data-core'
  def geoss_collection?(entry_node)
    is_geoss = false
    if entry_node.name == 'tag'
      value = ''
      entry_node.children.each do |tag_node|
        value = tag_node.content if tag_node.name == 'tagKey'
      end
      if (value == Rails.configuration.geoss_data_core_tag)
        is_geoss = true
      end
    end
    is_geoss
  end

  # a CEOS collection exists and results in a creation of a echo:is_ceos element with value 'true' if the collection
  # belongs to a CEOS data center or a CEOS achive center. The CEOS data centers or archive centers lists are maintained
  # in the CMR OpenSearch environment specific application configuration.
  def ceos_collection?(entry_node)
    is_ceos = false
    data_center = entry_node.at_xpath('echo:dataCenter', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')
    archive_center = entry_node.at_xpath('echo:archiveCenter', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')
    organizations = entry_node.xpath('echo:organization', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom')
    if (cmr_params != nil)
      if ((!data_center.nil? && cmr_params[:data_center] != nil && ceos_configured_collection?(cmr_params[:data_center],data_center.text)) ||
          (!archive_center.nil? && cmr_params[:data_center] != nil && ceos_configured_collection?(cmr_params[:data_center], archive_center.text)))
        is_ceos = true
      end
      if !is_ceos && organizations.size >= 1
        organizations.each do |organization|
          if (!organization.text.blank?  && cmr_params[:data_center] != nil && ceos_configured_collection?(cmr_params[:data_center], organization.text))
            is_ceos = true
            break
          end
        end
      end
    end
    is_ceos
  end

  # an EOSDIS collection exists and results in a creation of a echo:is_esdis element with value 'true' if the collection
  # is tagged with the appropriate namespace (TBD / configurable)
  def eosdis_collection?(entry_node)
    is_eosdis = false
    if entry_node.name == 'tag'
      value = ''
      entry_node.children.each do |tag_node|
        value = tag_node.content if tag_node.name == 'tagKey'
      end
      if (value == Rails.configuration.eosdis_tag)
        is_eosdis = true
      end
    end
    is_eosdis
  end

  # There is a reason we don't simplify this by using xpath. It is really slow over large result sets. Slow enough to generate user complaints.
  def add_collection_summary(data_center, doc, entry, short_name, version_id, description = nil)
    summary = "<p><b>Short Name: </b>#{short_name} <b>Version ID: </b>#{version_id} <b>Data Center: </b>#{data_center}</p>"
    description = nil
    entry.children.each do |node|
      description = node.content if node.name == 'summary'
    end
    summary += "<p><b>Description</b></p><p>#{description}</p>" unless description.nil?
    summary_element = add_common_summary(doc, entry, summary)
    entry.add_child(summary_element)
  end

  def to_cmr_collection_params params
    cmr_collection_params = {}
    cmr_collection_params[:keyword] = params[:keyword] unless params[:keyword].blank?
    cmr_collection_params[:campaign] = params[:campaign] unless params[:campaign].blank?
    cmr_collection_params[:sensor] = params[:sensor] unless params[:sensor].blank?
    cmr_collection_params[:processing_level] = params[:processingLevel] unless params[:processingLevel].blank?
    cmr_collection_params[:echo_collection_id] = params[:uid] unless params[:uid].blank?
    cmr_collection_params[:include_facets] = params[:include_facets] unless params[:include_facets].blank?
    cmr_collection_params[:has_granules] = params[:hasGranules] unless params[:hasGranules].blank?
    cmr_collection_params[:provider] = params[:provider] unless params[:provider].blank?

    # We need this additional information to determine whether to create a granule level OSDD or not
    cmr_collection_params[:include_has_granules] = true
    cmr_collection_params[:include_tags] = "#{Rails.configuration.cwic_tag},#{Rails.configuration.granule_osdd_tag},#{Rails.configuration.geoss_data_core_tag},#{Rails.configuration.eosdis_tag} "
    tag_keys = ''
    # only match CWIC collections if search parameter is present
    tag_keys = 'org.ceos.wgiss.cwic.granules.prod' if params[:isCwic] && params[:isCwic] == 'true'
    # only match GEOSS collections if search parameter is present
    if params[:isGeoss] && params[:isGeoss] == 'true'
      tag_keys.concat(',') unless tag_keys.blank?
      tag_keys.concat(Rails.configuration.geoss_data_core_tag)
    end
    # only match EOSDIS collections if search parameter is present
    if params[:isEosdis] && params[:isEosdis] == 'true'
      tag_keys.concat(',') unless tag_keys.blank?
      tag_keys.concat(Rails.configuration.eosdis_tag)
    end

    cmr_collection_params[:tag_key] = tag_keys unless tag_keys.blank?

    cmr_params = to_cmr_params(params)
    if params[:isCeos] && params[:isCeos] == 'true'
      ceoss_agencies_collections_cmr_params = CeosAgency.create_all_ceos_agencies_cmr_query_string(Rails.configuration.ceos_agencies)
      cmr_params.merge! ceoss_agencies_collections_cmr_params
    end

    cmr_collection_params.merge! cmr_params
    cmr_collection_params
  end

  def add_geoss(doc, node)
    geoss_node = Nokogiri::XML::Node.new 'echo:is_geoss', doc
    geoss_node.content = 'true'
    node.add_child(geoss_node)
    node
  end

  def add_ceos(doc, node)
    ceos_node = Nokogiri::XML::Node.new 'echo:is_ceos', doc
    ceos_node.content = 'true'
    node.add_child(ceos_node)
    node
  end

  def add_eosdis(doc, node)
    eosdis_node = Nokogiri::XML::Node.new 'echo:is_eosdis', doc
    eosdis_node.content = 'true'
    node.add_child(eosdis_node)
    node
  end

  def ceos_configured_collection?(ceos_collections_array_with_wildcard, collection)
    ret_val = false
    ceos_collections_array_with_wildcard.each do |ceos_configured_collection|
      if collection.match(ceos_configured_collection)
        ret_val = true
        break
      end
    end
    ret_val
  end
end
