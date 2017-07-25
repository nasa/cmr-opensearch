class ApplicationController < ActionController::Base
  protect_from_forgery

  def log_performance(method, time, number_of_records = nil)
    log = "#{method} request with parameters #{params_to_logging(params)} took #{(time.to_f * 1000).round(0)} ms"
    unless number_of_records.nil?
      log.concat(" and returned #{number_of_records} hit")
      log.concat('s') if number_of_records == 0 || number_of_records > 1
    end
    log
  end

  def params_to_logging(params)
    params.delete('controller')
    params.delete('action')
    params.delete('commit')
    params.delete('utf8')
    params.delete_if {|key, value| value.nil? || (value.kind_of?(String) && value.empty?) }
    params
  end

  def destroy_token
    Rails.logger.info "Destroying Token ID: #{@token_id}"
    begin
      Token.delete(@token_id)
    rescue

    end
  end

  protected

  def extract_common_params
    @client_id = params[:clientId]

    # If format is html remove spatial constraints that do not match spatial type
    if request.format == :html

      @spatial_type = params[:spatial_type] || 'bbox'

      params[:boundingBox] = nil unless @spatial_type == 'bbox'
      params[:geometry] = nil unless @spatial_type == 'geometry'
      params[:placeName] = nil unless @spatial_type == 'placename'
    end

    @number_of_results = params[:numberOfResults].blank? ? 10 : params[:numberOfResults]
    params[:numberOfResults] = @number_of_results
    @cursor = params[:cursor].blank? ? 1 : params[:cursor]
    # do not default offset, the impact to existing code is not worth it
    # per CEOS-BP-007, if both offset and cursor are present, offset (startIndex) preceeds cursor (startPage)
    @offset = params[:offset]
    if !params[:offset].blank?
      params[:cursor] = nil
      @cursor = nil
    end
    if !@cursor.blank?
      params[:cursor] = @cursor
    end
  end

  def extract_query_params params
    query_params = params.dup
    query_params.delete :action
    query_params.delete :controller
    query_params.delete :format
    query_params.delete :utf8
    query_params.delete :spatial_type
    query_params.delete :commit
    query_params.delete :collection_cursor
    query_params.delete :collection_number_of_results

    query_params[:dataset_id] = params[:datasetId]
    query_params.delete :datasetId

    # Remove facet parameters
    query_params.delete :facetLimit
    query_params.delete :facetCount
    query_params.delete :facetStart
    query_params.delete :facetSort
    query_params
  end

end
