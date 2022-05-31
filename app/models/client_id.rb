class ClientId
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :clientId

  validates :clientId,
            format: {
              with: /\A[a-zA-Z0-9_\-]+\z/,
              message: 'is invalid, it must be an alpha-numeric string'
            },
            allow_blank: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value) if %w[clientId].include? name.to_s
    end
  end

  def persisted?
    false
  end
end
