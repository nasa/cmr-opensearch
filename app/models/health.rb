class Health
  # things to check: CMR search

  def initialize
    @cmr_ok = cmr_status
  end

  def ok?
    @cmr_ok
  end

  private

  def cmr_status
    ok = false
    response = nil
    begin
      response = RestClient::Request.execute :method => :get, :url => "#{ENV['catalog_rest_endpoint']}health", :verify_ssl => OpenSSL::SSL::VERIFY_NONE
      ok = response.body.include?("\"ok?\":true") && !response.body.include?(':false')
    rescue
      ok = false
    end
    ok
  end
end