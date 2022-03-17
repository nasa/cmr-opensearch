# This initializer will run all the CMR OpenSearch scheduled tasks
# If various durations are needed for various scheduler tasks, different scheduler runs should be used for individual
# tasks
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.singleton

ENDPOINT = "#{ENV['opensearch_url']}/granules/descriptor_document.xml"

# Log the holdings every Sunday at midnight
unless scheduler.down?
  scheduler.cron('58 23 * * 6') do
    providers, total_collection_hits, total_granule_hits = Holding.all

    Rails.logger.info("DSR Total no. of collections: #{total_collection_hits}")
    Rails.logger.info("DSR Total no. of granules: #{total_granule_hits}")

    providers.each do |provider|
      Rails.logger.info("DSR #{provider[0]} no. of collections: #{provider[1].collections}")
      Rails.logger.info("DSR #{provider[0]} no. of granules: #{provider[1].granules}")
    end
  end

  if %w[production development].include?(ENV['RAILS_ENV'])
    # cache cwic holdings every saturday at 1 am
    cwic_providers_cache = Holding.get_cwic_provider_cache
    cwic_providers = Holding.parse_cwic_mapping
    cwic_providers_cache = Holding.remove_deleted_cwic_collections(cwic_providers_cache, cwic_providers)

    cwic_providers.each do |provider, collections|
      # create a cron for each provider, the multi-threaded approache with Thread.new was blocking the main thread.
      scheduler.cron '00 01 * * 6', first_in: '3s' do
        unless %w[CCMEO EUMETSAT].include? provider
          time = Benchmark.realtime do
            Rails.logger.info("Starting granule count update cron from provider: #{provider}.")
            collections.each do |concept_id, dataset_id|
              url = ENDPOINT + "?collectionConceptId=#{concept_id}&clientId=echo-access"

              begin
                descriptor_document = RestClient.get url
              rescue StandardError => e
                Rails.logger.info("CWIC providers cron failed get on URL: #{url} with message #{e.message}.")
              end

              descriptor_document = Nokogiri::XML.parse(descriptor_document)
              descriptor_document.remove_namespaces!

              url = descriptor_document.xpath('/OpenSearchDescription/Url[1]/@template').text.gsub(
                /&\w+=\{.*?\}|\w+=\{.*?\}&/, ''
              )

              next unless url.present?

              begin
                Rails.logger.info("Fetching #{url}")
                granule_response = RestClient::Request.execute(method: :get, url: url, timeout: 360)
                granule_response = Nokogiri::XML.parse(granule_response)
                granule_response.remove_namespaces!

                granule_count = granule_response.xpath('/feed/totalResults').text.to_i
                collection_found = false

                if granule_count.present?
                  cwic_providers_cache[provider].map do |collection|
                    next unless collection['id'] == concept_id

                    collection_found = true

                    Rails.logger.info("Updating #{provider}, concept_id: #{concept_id}, datasetid: #{dataset_id}, granule count from #{collection['count']} to #{granule_count}.")

                    collection['datasetid'] = dataset_id
                    collection['count'] = granule_count
                  end
                end

                if collection_found == false
                  Rails.logger.info("Updating #{provider}, adding concept_id: #{concept_id}, datasetid: #{dataset_id}, granule count: #{granule_count}.")

                  cwic_providers_cache[provider].push({ id: concept_id, datasetid: dataset_id, count: granule_count })
                end

              rescue StandardError => e
                Rails.logger.info("CWIC providers cron failed for provider #{provider}, GET on URL: #{url} with message #{e.message}.")
              end
            end
          end

          Rails.logger.info("Update cron finished for provider #{provider} in #{time} seconds.")
          Rails.cache.write('cwic_holdings', cwic_providers_cache)
        end
      end
    end
  end
end
