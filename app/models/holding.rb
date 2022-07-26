class Holding
  def self.find(provider)
    Rails.cache.read("holdings-#{provider.downcase}") || {}
  end
end