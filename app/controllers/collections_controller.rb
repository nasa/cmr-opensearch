class CollectionsController < ApplicationController
  respond_to :xml, :only => :descriptor_document
  respond_to :xml, :only => :descriptor_document_facets
  respond_to :atom, :html, :only => :index

  # GET datasets/descriptor_document.xml
  def descriptor_document
    @client_id_model = ClientId.new(params)

    @type = 'datasets'

    if @client_id_model.valid?
      respond_to do |format|
        format.xml
      end
    else
      error_msg = ''
      @client_id_model.errors.full_messages.each { |value| error_msg += "#{value}\n" }
      flash.now[:error] = error_msg.chop!
      render 'home/index.html.erb', :status => :bad_request
    end
  end

  def descriptor_document_facets
    @client_id_model = ClientId.new(params)

    @type = 'datasets'

    if @client_id_model.valid?
      respond_to do |format|
        format.xml
      end
    else
      error_msg = ''
      @client_id_model.errors.full_messages.each { |value| error_msg += "#{value}\n" }
      flash.now[:error] = error_msg.chop!
      render 'home/index.html.erb', :status => :bad_request
    end
  end

  # GET collections.[atom|html]
  def index
    time = Benchmark.realtime do
      extract_params
      # Cwic-User = test will provide links to CWIC OSDDs for datasets that are not yet public
      cwic_testing = request.headers['Cwic-User']
      if !cwic_testing.nil? && cwic_testing.upcase == 'TEST'
        cwic_testing = true
      else
        cwic_testing = false
      end

      @has_granules_type = params[:hasGranules] || nil
      @is_cwic_type = params[:isCwic] || nil
      @is_geoss_type = params[:isGeoss] || nil
      @is_ceos_type = params[:isCeos] || nil
      @is_eosdis_type = params[:isEosdis] || nil
      @is_fedeo_type = params[:isFedeo] || nil
      @collection_models = []
      @number_of_hits = 0
      @collection = nil
      facet_processing_required = false

      begin
        @time = 0
        collections = nil
        query_params = extract_query_params params
        @collection = Collection.new(query_params)
        if @collection.valid?
          # do not affect the OpenSearch param validation and only apply facets to datasets
          facet_params = Facet.extract_facet_params(params)
          facet_processing_required = Facet.processing_required(facet_params)
          if (facet_processing_required)
            query_params[:include_facets] = true
          end
          collections = @collection.find(query_params, request.original_url, request.format == :atom, cwic_testing)

          @number_of_hits = Collection.hits collections
          @client_id = params[:clientId] || 'unknown'

          if request.format == :html
            @client_id = 'our_html_ui'
            @collection_models = Collection.to_html_model collections
          end
        end
      rescue => e
        Rails.logger.error "Client ID '#{params[:clientId]}' collection search error: " + e.inspect
      end

      respond_to do |format|
        format.atom do
          if @collection.valid? && !collections.nil?
            if (facet_processing_required)
              Facet.process_facet_search(collections, facet_params)
            end
            text = collections.to_xml(:indent => 2)
            render :plain => text
          else
            if @collection.errors.count > 0
              text = @collection.errors.to_xml(:indent => 2)
              render :plain => text, :status => :bad_request and return
            else
              Rails.logger.error "Collection search exception: #{e}"
              if (!e.nil? && !e.response.code.nil?)
                # need separate rendering for exceptions since they cannot be added to ActiveModel errors modified hash
                render :plain => e.response, :status => e.response.code and return
              end
            end
          end
        end
        format.html
      end
    end
    Rails.logger.info log_performance('Collection search', time, @number_of_hits)
  end

  private

  def extract_params
    extract_common_params
  end

end      
