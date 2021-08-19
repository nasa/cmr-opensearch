require 'json'

class Token

  def self.get(base64_creds)
    response = RestClient.post "#{ENV['edl_endpoint']}/token", {}, {:Authorization => "Basic #{base64_creds}"}

    token_id = JSON.parse(response.body)["access_token"]
    return token_id
  end

  def self.delete(token_id)
    RestClient.delete "#{ENV['edl_endpoint']}/revoke_token?token=#{token_id}", {:Authorization => "Basic #{base64_creds}"}
  end
end