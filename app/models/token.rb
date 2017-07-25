class Token

  def self.get(client_id)
    # For our metrics purposes the client id we send to echo is the user supplied client id + open search tag + OPS/PT/TB
    composite_client_id = "#{client_id}-opensearch-#{ENV['mode']}"
    payload = "<token>
          <username>guest</username>
          <password>guest@echo.nasa.gov</password>
          <client_id>#{composite_client_id}</client_id>
          <user_ip_address>0.0.0.0</user_ip_address>
        </token>"
    response = RestClient::Request.execute :method => :post, :url => "#{ENV['echo_rest_endpoint']}/tokens",
                                           :payload => payload, :verify_ssl => OpenSSL::SSL::VERIFY_NONE,
                                           :headers => {:content_type => 'application/xml'}

    token_id = Nokogiri::XML(response.to_str).xpath('token/id').first.to_str
    return token_id
  end

  def self.delete(token_id)
    RestClient.delete "https://api.echo.nasa.gov/echo-rest/tokens/#{token_id}", {:echo_token => token_id}
  end
end