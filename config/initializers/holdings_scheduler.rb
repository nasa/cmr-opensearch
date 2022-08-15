require 'json'
require 'rufus-scheduler'
require 'securerandom'

include GranulesHelper

scheduler = Rufus::Scheduler.singleton

QUERY = <<~GRAPH_QUERY.freeze
  query OpenSearchProviderCollections(
    $provider: String
    $providers: [String]
    $dataCenter: String
    $dataCenters: [String]
  ) {
    collections (params: {
      provider: $provider,
      providers: $providers,
      dataCenter: $dataCenter,
      dataCenters: $dataCenters,
      includeTags: "opensearch.granule.osdd, org.ceos.wgiss.cwic.granules.provider, org.ceos.wgiss.cwic.granules.native_id",
      limit: 1000
    }){
      count
      items {
        conceptId
        title
        tags
        relatedUrls
      }
    }
  }
GRAPH_QUERY

# get_collections
#
# @param [Hash] params Search parameters
# @param [String] request_id A GUID to send GraphQL for logging
#
# @return [RestClient::Response] Parsed response from GraphQL
def get_collections(params, request_id)
  graphql_response = RestClient::Request.execute(
    method: :post,
    url: Rails.configuration.graphql_endpoint,
    headers: {
      accept: :json,
      content_type: :json, 
      'Client-Id': "opensearch-#{Rails.env.downcase}-background",
      'X-Request-Id': request_id
    },
    payload: {
      query: QUERY,
      variables: params
    }.to_json
  )

  # Parse the results from GraphQL
  results = JSON.parse(graphql_response)

  # Return the results defaulting to an empty hash
  results.fetch('data', {}).fetch('collections', {})
rescue StandardError => e
  puts "#{request_id} - #{e}"

  # Return an empty hash on error
  {}
end

# Log the holdings every Sunday at midnight
unless scheduler.down?
  scheduler.cron '00 01 * * 6', first_in: '3s' do
    if %w[production development].include?(ENV['RAILS_ENV'])
      cwic_providers_cache = {}

      Rails.configuration.holdings_providers.each do |query_config|
        provider = query_config['provider']

        begin
          params = query_config.fetch('params', {})

          # Create a GUID that we include in each of our logs and send to GraphQL to better match requests
          logging_request_id = SecureRandom.uuid

          results = get_collections(params, logging_request_id)

          collection_count = results.fetch('count', 0)

          puts "#{logging_request_id} - #{provider} - - CMR indicates #{collection_count} collection(s)."

          next unless collection_count.positive?

          previous_provider_cache = Rails.cache.read("holdings-#{provider.downcase}") || {}

          cwic_providers_cache = (previous_provider_cache).merge({
            'count' => collection_count,
            'last_requested_at' => Time.now.utc.iso8601,
            'items' => {}
          })

          results['items'].each do |collection|
            granule_descriptor_start = Time.now

            concept_id = collection['conceptId']
            title = collection['title']

            item_to_cache = cwic_providers_cache['items'].fetch(concept_id, {}).merge({ 'entry_title' => title })

            error_message = nil

            begin
              granule_url = determine_granule_url(collection)

              if granule_url.blank?
                error_message = "No granule url found in tags or related url metadata."

                puts "#{logging_request_id} - #{provider} - #{concept_id} - #{error_message}"

                item_to_cache['last_error'] = error_message
                item_to_cache['last_requested_at'] = Time.now.utc.iso8601
              end

              unless granule_url.blank?
                descriptor_document = RestClient::Request.execute(method: 'get', url: granule_url, timeout: 30)
                descriptor_document = Nokogiri::XML.parse(descriptor_document)
                descriptor_document.remove_namespaces!

                puts "#{logging_request_id} - #{provider} - #{concept_id} - Granule descriptor successful after #{Time.now - granule_descriptor_start} seconds."

                # Strip all the unset template variables from the string
                url = descriptor_document.xpath('/OpenSearchDescription/Url[@type="application/atom+xml" and @rel="results"]/@template').text.gsub(
                  /&\w+=\{.*?\}|\w+=\{.*?\}&/, ''
                )

                if url.blank?
                  error_message = "No granule search URL found in the granule descriptor (#{granule_url})."

                  puts "#{logging_request_id} - #{provider} - #{concept_id} - #{error_message}\n#{descriptor_document}"

                  item_to_cache['last_error'] = error_message
                  item_to_cache['last_requested_at'] = Time.now.utc.iso8601
                else
                  puts "#{logging_request_id} - #{provider} - #{concept_id} - Found granule search URL #{url}"
                end
              end
            rescue StandardError => e
              error_message = "Granule descriptor failed after #{Time.now - granule_descriptor_start} seconds with message \"#{e.message}\" (URL: #{granule_url})."

              puts "#{logging_request_id} - #{provider} - #{concept_id} - #{error_message}"

              item_to_cache['last_error'] = error_message
            end

            granule_search_start = Time.now

            unless url.blank?
              begin
                granule_response = RestClient.get(url)
                granule_response = Nokogiri::XML.parse(granule_response)
                granule_response.remove_namespaces!

                puts "#{logging_request_id} - #{provider} - #{concept_id} - Granule search successful after #{Time.now - granule_search_start} seconds."

                granule_count = granule_response.xpath('/feed/totalResults').text.to_i

                # If this collection as previously been retrieved
                if granule_count
                  puts "#{logging_request_id} - #{provider} - #{concept_id} - #{granule_count} granules found."

                  item_to_cache['count'] = granule_count
                  item_to_cache['updated_at'] = Time.now.utc.iso8601

                  item_to_cache.delete('last_error')
                  item_to_cache.delete('last_requested_at')
                end
              rescue StandardError => e
                error_message = "Granule search failed after #{Time.now - granule_search_start} seconds with message \"#{e.message}\" (URL: #{url}))."

                puts "#{logging_request_id} - #{provider} - #{concept_id} - #{error_message}"

                collection['last_error'] = error_message
              end
            end

            if error_message
              item_to_cache['last_error'] = error_message
              item_to_cache['last_requested_at'] = Time.now.utc.iso8601
            end

            cwic_providers_cache['items'][concept_id] = item_to_cache
          end
        rescue StandardError => e
          error_message = "GraphQL query to retrieve collections failed with message \"#{e.message}\"."

          puts "#{logging_request_id} - #{provider} - #{error_message}"

          results['last_error'] = error_message
        end

        # Only write the updated_at value if there are items that were retrieved
        cwic_providers_cache['updated_at'] = Time.now.utc.iso8601

        # Updates the cache for this provider
        Rails.cache.write("holdings-#{provider.downcase}", cwic_providers_cache)
      end
    end
  end
end
