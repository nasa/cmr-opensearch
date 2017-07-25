class GranulesController < ApplicationController
  respond_to :xml, :only => :descriptor_document
  respond_to :atom, :html, :only => :index

  # GET granules/descriptor_document.xml
  def descriptor_document
    @client_id_model = ClientId.new(params)

    @short_name = params[:shortName].blank? ? '{echo:shortName?}' : params[:shortName]
    @version_id = params[:versionId].blank? ? '{echo:versionId?}' : params[:versionId]
    @data_center = params[:dataCenter].blank? ? '{echo:dataCenter?}' : params[:dataCenter]

    @type = 'granules'

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

  # GET all granules.[atom|html]
  def index
    @time = Benchmark.realtime do
      extract_params

      @granule_models = []
      @number_of_hits = 0

      begin
        granules = nil
        query_params = extract_query_params params
        @granule = Granule.new(query_params)
        if @granule.valid?
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
            render :text => text
          else
            if @granule.errors.count > 0
              text = @granule.errors.to_xml(:indent => 2)
              if (text.include?("is not supported"))
                render :text => text, :status => :not_implemented
              else
                render :text => text, :status => :bad_request and return
              end
            else
              if (!e.nil? && !e.response.code.nil?)
                # need separate rendering for exceptions since they cannot be added to ActiveModel errors modified hash
                render :text => e.response, :status => e.response.code and return
              end
            end
          end
        end
        format.html
      end
    end
    Rails.logger.info log_performance('Granule search', @time, @number_of_hits)
  end

  private

  def extract_params
    extract_common_params

    session[:collection_cursor] = params[:collection_cursor] unless params[:collection_cursor].blank?
    session[:collection_number_of_results] = params[:collection_number_of_results] unless params[:collection_number_of_results].blank?

  end
end
