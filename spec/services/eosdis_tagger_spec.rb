require 'spec_helper'

describe EosdisTagger do

  before(:all) do
    @tagger = EosdisTagger.new
  end

  it 'should tag EOSDIS collections with one POST per provider' do
    VCR.use_cassette 'services/eosdis_collections', :record => :once, :decode_compressed_response => true do
      @tagger.execute_scheduled_task
      verify_tagged_collection('C179003030-ORNL_DAAC')
      verify_tagged_collections_count(6526)
    end
  end

  it 'should tag EOSDIS collections with one POST for all providers' do
    VCR.use_cassette 'services/eosdis_collections_one_post', :record => :once, :decode_compressed_response => true do
      @tagger.execute_scheduled_task_single_post
      verify_tagged_collection('C179003030-ORNL_DAAC')
      verify_tagged_collections_count(6525)
    end
  end


  private
  def verify_tagged_collection(concept_id)
    response = RestClient::Request.execute :method => :get, :url => "#{@tagger.catalog_rest_endpoint}collections",
                                           headers: {params: {:concept_id => concept_id, :tag_key => @tagger.tag}},
                                           :verify_ssl => OpenSSL::SSL::VERIFY_NONE
    if (response.code != 200)
      msg = "ERROR #{response.code} retrieving tag: #{@tagger.tag}"
      Rails.logger.info(msg)
      fail msg
    else
      response_xml = Nokogiri::XML(response.body)
      # must only get 1 hit
      expect('1').to eq(response_xml.xpath('results/hits').first.text)
      # must get the expected concept_id
      expect(concept_id).to eq(response_xml.xpath('results/references/reference/id').first.text)
    end
  end

  def verify_tagged_collections_count(expected_count)
    response = RestClient::Request.execute :method => :get, :url => "#{@tagger.catalog_rest_endpoint}collections",
                                           headers: {params: {tag_key: @tagger.tag}},
                                           :verify_ssl => OpenSSL::SSL::VERIFY_NONE
    hits = response.headers[:cmr_hits].to_i
    expect(hits).to eq(expected_count)
  end
end