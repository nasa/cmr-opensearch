class HealthController < ApplicationController
  respond_to :json

  def index
    health = Health.new
    response = "{\"cmr-search\":{\"ok?\":#{health.ok?}}}"
    respond_to do |format|
      format.json do
        render :plain => response, :status => health.ok? ? :ok : :service_unavailable
      end
    end
  end
end
