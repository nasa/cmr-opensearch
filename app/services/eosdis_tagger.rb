# Because CMR tagging is static, only collections for EOSDIS PROVIDERS that exist when the tagging association is executed
# are tagged.  That means that if new EOSDIS providers and new providers collections are added, they must be tagged
# separately.

# This class provides functionality to tag all of EOSDIS providers collections.  It wil run as part of a scheduled task.
class EosdisTagger
  # array of EOSDIS providers identifiers
  # this array must be updated when new EOSDIS providers are added, tricky proposition
  attr_accessor :EOSDIS_PROVIDERS
  EOSDIS_PROVIDERS = Rails.configuration.eosdis_providers

  attr_accessor :token, :catalog_rest_endpoint, :cmr_base_endpoint, :tag

  def initialize
    # token used for tagging, grants tagging permissions to caller
    @token = "#{ENV['CMR_ECHO_SYSTEM_TOKEN']}"
    @catalog_rest_endpoint = "#{ENV['public_catalog_rest_endpoint']}"
    @cmr_base_endpoint = @catalog_rest_endpoint.gsub('search/', '')
    @ingest_providers_list_endpoint = "#{@cmr_base_endpoint}ingest/providers"

    # tag to process
    @tag = Rails.configuration.eosdis_tag
    @all_providers = Hash.new
    @tagged_providers = Hash.new
    @tagging_errors = Hash.new
  end

  # this is an alternate tagging mechanism that we can use if the single post is difficult to debug
  def execute_scheduled_task
    Rails.logger.info "EOSDISTagger START run of scheduled EOSDIS tagging task: #{Time.now}, catalog_rest_endpoint: #{@catalog_rest_endpoint}, cmr_base_endpoint: #{@cmr_base_endpoint}, ingest_providers_list_endpoint: #{@ingest_providers_list_endpoint}"
    time = Benchmark.realtime do
      verify_tag_presence
      populate_providers_hash
      EOSDIS_PROVIDERS.each do |provider|
        tag_provider_collections(provider)
      end
      log_tagging_metrics
    end
    Rails.logger.info "EOSDIS collection tagging with ONE post request per provider took #{(time.to_f * 1000).round(0)} ms"
    Rails.logger.info "EOSDISTagger END run of scheduled EOSDIS tagging task: #{Time.now}"
  end

  # this is the current tagging mechanism being used in the rufus scheduled task
  def execute_scheduled_task_single_post
    Rails.logger.info "EOSDISTagger START run of scheduled EOSDIS tagging task single POST request: #{Time.now}, catalog_rest_endpoint: #{@catalog_rest_endpoint}, cmr_base_endpoint: #{@cmr_base_endpoint}, ingest_providers_list_endpoint: #{@ingest_providers_list_endpoint}"
    time = Benchmark.realtime do
      verify_tag_presence
      populate_providers_hash
      tag_provider_collections_single_post
      log_tagging_metrics
    end
    Rails.logger.info "EOSDIS collection tagging scheduled task with ONE post request took #{(time.to_f * 1000).round(0)} ms"
    Rails.logger.info "EOSDISTagger END run of scheduled EOSDIS tagging task single POST request: #{Time.now}"
  end

  def verify_tag_presence
    # verify that tag exists
    response = RestClient::Request.execute :method => :get, :url => "#{@catalog_rest_endpoint}tags/#{@tag}", :verify_ssl => OpenSSL::SSL::VERIFY_NONE
    if (response.code != 200)
      Rails.logger.info("ERROR #{response.code} retrieving tag: #{@tag}")
      # terminate task if the tag is not present
      exit(status=256)
    else
      Rails.logger.info("LOCATED TAG: #{@tag}")
    end
  end

  # this is an extra check that help with unexpected tagging results due to miss-spelling the provider id in the array above
  def populate_providers_hash
    # GET A LIST OF ALL PROVIDERS
    Rails.logger.info("Retrieving providers list from #{@ingest_providers_list_endpoint}")
    response = RestClient::Request.execute :method => :get, :url => "#{@ingest_providers_list_endpoint}", :verify_ssl => OpenSSL::SSL::VERIFY_NONE
    if (response.code != 200)
      Rails.logger.info("ERROR #{response.code} retrieving providers list")
      # terminate task if we cannot validate the providers names
      exit(status=256)
    else
      list_of_providers_hashes = JSON.parse!(response.body)
      list_of_providers_hashes.each do |hash|
        provider_id = hash['provider-id']
        @all_providers[provider_id] = 'Y'
      end
      Rails.logger.info("RETRIEVED A LIST OF ALL PROVIDERS, SIZE: #{list_of_providers_hashes.size}, LOOKUP SIZE: #{@all_providers.size}")
    end
  end

  def tag_provider_collections(provider)
    if !provider.blank?
      provider = provider.strip
      Rails.logger.info("Processing provider: #{provider}")
      #ensure that provider is present
      if (@all_providers[provider] != nil)
        Rails.logger.info("LOCATED PROVIDER: #{provider}")
        # COLLECTIONS ARE BEING TAGGED so let's check if there are collections for each provider
        # help with debugging of timing issues since the tagging occurs at midnight and perhaps the collections expected
        # in the results set are tagged after that
        response = RestClient::Request.execute :method => :get, :url => "#{@catalog_rest_endpoint}collections",
                                               headers: {params: {provider: provider}},
                                               :verify_ssl => OpenSSL::SSL::VERIFY_NONE
        hits = response.headers[:cmr_hits].to_i
        if hits > 0
          Rails.logger.info("PROVIDER #{provider} HAS #{hits} COLLECTIONS")
          post_body = '{"condition": {"provider": "' + provider + '"}}'
          response = RestClient::Request.execute :method => :post, :url => "#{@catalog_rest_endpoint}tags/#{@tag}/associations/by_query", :payload => post_body,
                                                 :headers => {'Authorization' => @token, 'Content-Type' => 'application/json'},
                                                 :verify_ssl => OpenSSL::SSL::VERIFY_NONE
          if (response.code != 200)
            Rails.logger.info("COULD NOT TAG PROVIDER: #{provider}, ERROR: " + response.code)
            @tagging_errors[provider] = response_code
          else
            Rails.logger.info("SUCCESSFULY TAGGED PROVIDER: #{provider}")
            @tagged_providers[provider] = 'tagged'
          end
        end
      else
        Rails.logger.info("COULD NOT LOCATE PROVIDER: #{provider}")
      end
    end
  end

  # added to prove that the debugging is much more complicated with a single request
  def tag_provider_collections_single_post
    post_body = nil
    post_body_providers = ''
    EOSDIS_PROVIDERS.each do |provider|
      if !provider.blank?
        provider = provider.strip
        Rails.logger.info("Processing provider: #{provider}")
        #ensure that provider is present
        if (@all_providers[provider] != nil)
          Rails.logger.info("LOCATED PROVIDER: #{provider}")
          # COLLECTIONS ARE BEING TAGGED so let's check if there are collections for each provider
          # help with debugging of timing issues since the tagging occurs at midnight and perhaps the collections expected
          # in the results set are tagged after that
          response = RestClient::Request.execute :method => :get, :url => "#{@catalog_rest_endpoint}collections",
                                                 headers: {params: {provider: provider}},
                                                 :verify_ssl => OpenSSL::SSL::VERIFY_NONE
          hits = response.headers[:cmr_hits].to_i
          if hits > 0
            Rails.logger.info("PROVIDER #{provider} HAS #{hits} COLLECTIONS")
            post_body_providers = post_body_providers + '{"provider": "' + provider + '"},'
          end
        else
          Rails.logger.info("COULD NOT LOCATE PROVIDER: #{provider}")
        end
      end
    end
    if (!post_body_providers.blank?)
      post_body_providers = post_body_providers.chomp(',')
      post_body = '{
            "condition": {"or" : [' + post_body_providers +
          ']}}'
      Rails.logger.info("POST request body: #{post_body}")
      # one request takes much longer so we must increase the read_timeout (seconds)
      response = RestClient::Request.execute :method => :post, :url => "#{@catalog_rest_endpoint}tags/#{@tag}/associations/by_query", :payload => post_body,
                                             :headers => {'Authorization' => @token, 'Content-Type' => 'application/json'},
                                             :verify_ssl => OpenSSL::SSL::VERIFY_NONE, :timeout => 240
      if (response.code != 200)
        Rails.logger.info("COULD NOT TAG PROVIDERS, ERROR: #{response.code}, BODY: #{response.body} ")
      else
        Rails.logger.info("SUCCESSFULY TAGGED ALL PROVIDERS")
      end
    end
  end

  # summary of tagging run
  def log_tagging_metrics
    Rails.logger.info("TOTAL INPUT PROVIDERS: #{EOSDIS_PROVIDERS.size}")
    Rails.logger.info("INPUT PROVIDERS: #{EOSDIS_PROVIDERS}")

    Rails.logger.info("TOTAL TAGGED PROVIDERS (providers with associated collections): #{@tagged_providers.size}")
    Rails.logger.info("TAGGED PROVIDERS (providers with associated collections): #{@tagged_providers.keys}")

    Rails.logger.info("TOTAL ERRORS TAGGING PROVIDERS: #{@tagging_errors.size}")
    Rails.logger.info("PROVIDERS THAT FAILED TAGGING: #{@tagging_errors}")
  end
end