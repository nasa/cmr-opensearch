class HoldingsController < ApplicationController
  respond_to :json

  def index
    @holdings = {}

    Rails.configuration.holdings_providers.each do |query_config|
      provider = query_config['provider']

      holding = Holding.find(provider)

      @holdings[provider.downcase] = {
        'collections'       => holding.fetch('count', 0),
        'granules'          => holding.fetch('items', {}).map { |key, value| value.fetch('count', 0) }.sum,
        'last_error'        => holding['last_error'],
        'last_requested_at' => holding['last_requested_at'],
        'updated_at'        => holding['updated_at']
      }
    end

    respond_to do |format|
      format.json do
        render :json => @holdings, :status => :ok
      end
    end
  end

  def show
    @holdings = Holding.find(params[:id])

    respond_to do |format|
      format.json do
        if @holdings.blank?
          render :json => "{\"error\":\"Provider `#{params[:id]}` not found\"}", status: :not_found
        else
          render :json => @holdings, :status => :ok
        end
      end
    end
  end
end