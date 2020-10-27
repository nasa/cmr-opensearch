class GranulesController < ApplicationController
  include GranulesHelper
  respond_to :xml, :only => :descriptor_document
  respond_to :atom, :html, :only => :index

  # GET granules/descriptor_document.xml
  def descriptor_document
    @client_id_model = ClientId.new(params)

    @collection_concept_id = params[:collectionConceptId].blank? ? nil : params[:collectionConceptId]
    @short_name = params[:shortName].blank? ? '{echo:shortName?}' : params[:shortName]
    @version_id = params[:versionId].blank? ? '{echo:versionId?}' : params[:versionId]
    @data_center = params[:dataCenter].blank? ? '{echo:dataCenter?}' : params[:dataCenter]

    @type = 'granules'
    if @client_id_model.valid?
      if @collection_concept_id.present?
        mapping_hash = parse_cwic_mapping_by_concept_id(@collection_concept_id)
        if mapping_hash['erb_file'].present?
          if mapping_hash['dataset_id'].present?
            @dataset_id = URI.encode mapping_hash['dataset_id']
            @geo_box = mapping_hash['geo_box'].include?("unknown") ? '{geo:box}' : mapping_hash['geo_box']
            @begin = mapping_hash['begin'] == "unknown" ? '1970-01-01T00:00:00Z' : mapping_hash['begin']
            @end = mapping_hash['end'] == "unknown" ? '2030-01-01T00:00:00Z' : mapping_hash['end']
            render mapping_hash['erb_file']
          else
            error_msg = "Unable to find dataset_id for #{@collection_concept_id}"
            flash.now[:error] = error_msg.chop!
            render 'home/index.html.erb', :status => :bad_request
          end
        else
          error_msg = "Unable to find mapping for collectionConceptId #{@collection_concept_id}"
          flash.now[:error] = error_msg.chop!
          render 'home/index.html.erb', :status => :bad_request
        end
      else
        respond_to do |format|
          format.xml
        end
      end
    else
      error_msg = ''
      @client_id_model.errors.full_messages.each {|value| error_msg += "#{value}\n"}
      flash.now[:error] = error_msg.chop!
      render 'home/index.html.erb', :status => :bad_request
    end
  end

  # GET all granules.[atom|html]
  # the commit = Search parameter indicates a form submission
  # on a form submission we do not allow searches without the collection shortname or conceptid
  def index
    # if two_step_search
      @time = Benchmark.realtime do
        # do not allow the unrestricted granule seach if via the granule search form unless accessed as step 2 of a 2 step
        # search, where step 1 narrows down the search to a collection
        # Unrestricted granule searches are allowed via the API
        is_two_step_search = two_step_search
        extract_params

        @granule_models = []
        @number_of_hits = 0

        begin
          granules = nil
          query_params = extract_query_params params
          @granule = Granule.new(query_params)
          if (params[:commit] == 'Search')
            # validate form submission and avoid resource intensive searches while allowing them if invoked vai the OpenSearch API
            @granule.invokedFromSearchForm = true
          else
            @granule.invokedFromSearchForm = false
          end
          # allow the unrestricted granule search only via the OpenSearch ATOM API or via the granule HTML search form if
          # a.  The search is part of a two step search OR
          # b.  The search is invoked directly and it has the required search parameters (Collection Concept IF, Short name
          # or Unique ID) which are part of the granule model validation specific to a form submission
          if @granule.valid? && (is_two_step_search || request.format == 'application/atom+xml')
            granules = @granule.find(query_params, request.original_url)

            @number_of_hits = Granule.hits granules
            @client_id = params[:clientId] || 'unknown'

            if request.format == :html
              @client_id = 'our_html_ui'
              @granule_models = Granule.to_html_model granules
            end

          end

        rescue => e
          Rails.logger.error "Client ID '#{params[:clientId]}' granule search error: " + e.inspect
        end
        respond_to do |format|
          format.atom do
            text = ''
            if @granule.valid? && !granules.nil?
              text = granules.to_xml(:indent => 2)
              render :plain => text
            else
              if @granule.errors.count > 0
                text = @granule.errors.to_xml(:indent => 2)
                if (text.include?("is not supported"))
                  render :plain => text, :status => :not_implemented
                else
                  render :plain => text, :status => :bad_request and return
                end
              else
                if (!e.nil? && !e.response.code.nil?)
                  # need separate rendering for exceptions since they cannot be added to ActiveModel errors modified hash
                  render :plain => e.response, :status => e.response.code and return
                end
              end
            end
          end
          format.html do
            if @client_id.blank?
              @client_id = 'our_html_ui'
            end
          end
        end
        Rails.logger.info log_performance('Granule search', @time, @number_of_hits)
      end
    #else
    #  respond_to do |format|
    #    format.html
    #  end
    #end
  end

  private

  def extract_params
    extract_common_params

    session[:collection_cursor] = params[:collection_cursor] unless params[:collection_cursor].blank?
    session[:collection_number_of_results] = params[:collection_number_of_results] unless params[:collection_number_of_results].blank?

  end

  # the granule search form can be accessed directly without going through the recommended two-step search approach:
  # step 1: search for collections and identify the collection of interest
  # step 2: search for granules ONLY in the collection of interest indentified in step 1
  def two_step_search
    ret_val = true
    if params.values.size == 2 && params['action'] == 'index' && params['controller'] == 'granules'
      ret_val = false
    end
    return ret_val
  end
end
