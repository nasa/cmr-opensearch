class Holding
  ENDPOINT = "#{ENV['cmr_search_endpoint']}/provider_holdings.json"
  OPENSEARCH_ENDPOINT = "#{ENV['opensearch_url']}"
  MERGEABLE_PROVIDERS = []
  PREFIX_PROVIDERS = {'MOSDAC' => 'ISRO','NRSC' => 'ISRO'}
  RENAME_PROVIDERS = {'GHRSST' => 'NOAA_NCEI'}

  def self.get_cwic_provider_cache
    cwic_providers = nil

    if Rails.cache.read('cwic_holdings').nil?
      cwic_providers = initialize_cwic_providers()
      Rails.cache.write('cwic_holdings', cwic_providers)
    else
      cwic_providers = Rails.cache.read('cwic_holdings')
    end

    cwic_providers
  end

  def self.all
    response = nil

    time = Benchmark.realtime do
      response = RestClient.get(ENDPOINT, {:echo_token => Rails.configuration.read_all_token})
    end

    Rails.logger.info("CMR Search collection search took : #{time.to_f.round(2)} seconds")

    results = response.to_str()
    collection_hits = response.headers[:cmr_collection_hits] ? response.headers[:cmr_collection_hits].to_i : 0
    granule_hits = response.headers[:cmr_granule_hits] ? response.headers[:cmr_granule_hits].to_i : 0

    providers = to_providers_hash(results)
    cwic_providers = get_cwic_provider_cache()
    split_cmr_and_cwic_providers(providers, collection_hits, granule_hits, cwic_providers)
  end

  def self.find_by_id(id, token = nil, is_cwic = 'false')
    cwic_providers = get_cwic_provider_cache()
    cwic_providers = rename_cwic_providers(cwic_providers)
    # Get the hits with the sys read token
    collection_hits = 0
    granule_hits = 0
    datasets = []

    if is_cwic != 'true'
      results, collection_hits, granule_hits = get_cmr_provider(id, token)
      datasets = to_datasets_hash(results)
    elsif cwic_providers.keys.include?(id) && ['production','test','development'].include?(ENV['RAILS_ENV']) && is_cwic == 'true'
      cwic_datasets = to_cwic_datasets_hash(cwic_providers[id])
      # For mergeable providers, we need to combine the entry-titles of CMR with the counts found in the cwic provider cache

      if MERGEABLE_PROVIDERS.include?(id)
        results, collection_hits, granule_hits = get_cmr_provider(id, token)

        cmr_datasets = to_datasets_hash(results)
        cmr_datasets.map do |cmr_dataset|
          count = cmr_dataset.granules
          temp_dataset = cwic_datasets.select{ |cwic_dataset| cwic_dataset.concept_id == cmr_dataset.concept_id }.first

          if temp_dataset.present?
            count = temp_dataset.granules
          end

          cmr_dataset.granules = count
        end

        cwic_datasets = cmr_datasets
      end

      datasets = cwic_datasets
      collection_hits = cwic_datasets.count
      granule_hits = cwic_datasets.map { |dataset| dataset.granules }.reduce(0, :+)
    end

    [datasets, collection_hits, granule_hits]
  end

  private

  def self.get_cmr_provider(id,token)
    response = nil

    time = Benchmark.realtime do
      response = RestClient.get(ENDPOINT, { params: { provider_id: id }, echo_token: Rails.configuration.read_all_token })
    end

    Rails.logger.info("CMR Search collection search for hits took : #{time.to_f.round(2)} seconds")

    collection_hits = response.headers[:cmr_collection_hits] ? response.headers[:cmr_collection_hits].to_i : 0
    granule_hits = response.headers[:cmr_granule_hits] ? response.headers[:cmr_granule_hits].to_i : 0

    # Get the results with the users' token
    time = Benchmark.realtime do
      if token.nil?
        response = RestClient.get(ENDPOINT, { params: { provider_id: id } })
      else
        response = RestClient.get(ENDPOINT, { params: { provider_id: id }, echo_token: token })
      end
    end

    Rails.logger.info("CMR Search collection search for results took : #{time.to_f.round(2)} seconds")

    results = response.to_str
    [results, collection_hits, granule_hits]
  end

  def self.initialize_cwic_providers
    file = File.read('cwic-holdings.json')
    JSON.parse(file)
  end

  def self.tabulate_cwic_counts(cwic_providers)
    temp_providers = {}
    cwic_collection_hits = 0
    cwic_granule_hits = 0

    cwic_providers.each do |provider, holdings|
      granule_count = 0
      collection_count = 0

      holdings.each do |holdings_hash|
        granule_count = granule_count + holdings_hash['count'].to_i
        collection_count = collection_count + 1
      end

      temp_providers[provider] = OpenStruct.new
      temp_providers[provider].collections = collection_count
      temp_providers[provider].granules = granule_count

      cwic_granule_hits += granule_count
      cwic_collection_hits += collection_count
    end

    temp_providers = rename_cwic_providers(temp_providers)
    [temp_providers, cwic_granule_hits, cwic_collection_hits]
  end

  # There are some cwic providers that are returned in the provider_holdings call to CMR, we
  # want to display those instead in the CWIC Provider holdings section, along with their counts
  def self.merge_mergeable_providers(providers, cwic_providers, granule_hits, collection_hits)
    MERGEABLE_PROVIDERS.each do |provider|
      if providers[provider]
        cwic_collection_ids = cwic_providers[provider].map do |collection_hash|
          collection_hash['id']
        end

        providers[provider].collection_ids.each do |collection|
          # If we encounter a collection in CMR holdings that isn't in the cwic collection conceptId
          # list for this CWIC provider, add it in.  Unfortunately we won't have a count so we use zero.
          if !cwic_collection_ids.include? collection
            collection_hash = { id: collection, datasetid: '', count: 0, status: 'active' }
            cwic_providers[provider] << collection_hash
          end
        end

        if providers[provider].present?
          granule_hits -= providers[provider].granules
          collection_hits -= providers[provider].collections
        end

        providers.delete(provider)
      end
    end

    # We don't want to display the provider holdings for these providers within Earthdata holdings
    PREFIX_PROVIDERS.each do |cwic_provider, cmr_provider|
      if providers[cmr_provider].present?
        granule_hits -= providers[cmr_provider].granules
        collection_hits -= providers[cmr_provider].collections
      end

      providers.delete(cmr_provider)
    end

    [providers, cwic_providers, granule_hits, collection_hits]
  end

  def self.rename_cwic_providers(cwic_providers)
    PREFIX_PROVIDERS.each do |provider, prefix|
      cwic_providers["#{prefix}/#{provider}"] = cwic_providers.delete(provider)
    end

    RENAME_PROVIDERS.each do |provider, new_name|
      cwic_providers[new_name] = cwic_providers.delete(provider)
    end

    cwic_providers
  end

  def self.split_cmr_and_cwic_providers(providers,collection_hits,granule_hits,cwic_providers)
    if ['production','test','development'].include?(ENV['RAILS_ENV'])
      providers, cwic_providers, granule_hits, collection_hits = merge_mergeable_providers(providers, cwic_providers, granule_hits, collection_hits)

      cwic_providers, cwic_granule_hits, cwic_collection_hits = tabulate_cwic_counts(cwic_providers)
    end

    [providers, cwic_providers, collection_hits, granule_hits, cwic_collection_hits, cwic_granule_hits]
  end

  def self.to_providers_hash(result_string)
    dataset_rep = JSON.parse(result_string)
    providers = {}

    dataset_rep.each do |dataset|
      if providers[dataset['provider-id']].nil?
        providers[dataset['provider-id']] = OpenStruct.new
        providers[dataset['provider-id']].collections = 1
        providers[dataset['provider-id']].collection_ids = [dataset['concept-id']]
        providers[dataset['provider-id']].granules = dataset['granule-count'].to_i
      else
        providers[dataset['provider-id']].collections = providers[dataset['provider-id']]['collections'] + 1
        providers[dataset['provider-id']].collection_ids.push dataset['concept-id']
        providers[dataset['provider-id']].granules = providers[dataset['provider-id']].granules + dataset['granule-count'].to_i
      end
    end

    providers
  end

  def self.to_cwic_datasets_hash(cwic_holdings_hash)
    datasets = []

    cwic_holdings_hash.each do |dataset|
      d = OpenStruct.new
      d.name = dataset['datasetid']
      d.concept_id = dataset['id']
      d.granules = dataset['count'].to_i
      datasets << d
    end

    datasets
  end

  def self.to_datasets_hash(result_string)
    dataset_rep = JSON.parse(result_string)
    datasets = []

    dataset_rep.each do |dataset|
      d = OpenStruct.new
      d.name = dataset['entry-title']
      d.concept_id = dataset['concept-id']
      d.granules = dataset['granule-count']
      datasets << d
    end

    datasets
  end

  def self.remove_deleted_cwic_collections(cwic_providers_cache,cwic_mapping)
    cwic_providers_cache.each do |provider, collections|
      collections.each do |collection|
        if cwic_mapping[provider].present?
          concept_ids, dataset_ids = cwic_mapping[provider].transpose

          if !concept_ids.include?(collection['id'])
            Rails.logger.info("Removing deleted collection from cache concept_id: #{collection['id']}.")

            cwic_providers_cache[provider].delete(collection)
          end
        else
          Rails.logger.info("Removing provider from cache: #{provider}.")

          cwic_providers_cache.delete(provider)
          break
        end
      end
    end

    Rails.cache.write('cwic_holdings', cwic_providers_cache)
    cwic_providers_cache
  end

  def self.parse_cwic_mapping
    cwic_mapping = File.read('cwic-mapping.xml')

    cwic_mapping_doc = Nokogiri::XML.parse(cwic_mapping)
    providers = cwic_mapping_doc.xpath('/mappingList/catalog/@id').to_a

    mapping_hash = Hash.new

    providers.each do |provider|
      unless provider.text == 'NASA'
        collection_ids = cwic_mapping_doc.xpath("/mappingList/catalog[@id=\"#{provider}\"]/dataSet/@conceptId").to_a
        dataset_ids = cwic_mapping_doc.xpath("/mappingList/catalog[@id=\"#{provider}\"]/dataSet/@datasetId").to_a

        dataset_ids.collect! { |dataset_ids|
          dataset_ids = dataset_ids.text
        }

        collection_ids.collect! { |collection_id|
          collection_id = collection_id.text
        }

        mapping_hash[provider.text] = collection_ids.zip(dataset_ids)
      end
    end

    mapping_hash
  end
end
