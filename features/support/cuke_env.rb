# These lines allow us to run cucumber with the -q option, which doesn't load env.rb
unless defined? ENV_LOADED
  ENV_LOADED = defined? ENV
  ENV ||= {'rest_root' => ''}
end

module CukeEnv
  def self.browser
    if ENV["browser"]
      @browser ||= ENV["browser"].to_sym
    else
      @browser ||= :firefox
    end
  end

  def self.host
    @host ||= (ENV["host"] or "localhost")
  end

  def self.port
    @port ||= (ENV["port"] or "3000")
  end

  def self.rails_root
    @rails_root ||= (ENV["rails_root"] or "")
  end

  def self.capybara_port
    (ENV["capybara_port"] && ENV["capybara_port"].to_i)|| 9887
  end

  # Returns true if fixtures should be loaded before starting cucumber tests
  # Defaults to false
  def self.load_fixtures?
    ENV["load_fixtures"] || ENV["reload_fixtures"]
  end

  def self.reload_fixtures?
      ENV["reload_fixtures"]
    end

  # Returns true if a cleanup should be performed before running cucumber tests.
  def self.cleanup_first?
    ENV["cleanup"] == "true"
  end

  def self.env_loaded?
    ENV_LOADED
  end

  #Returns the base URL of the application being tested.
  def self.url_base(include_rails_root = true)
    url = "http://#{host}:#{port}"
    if include_rails_root
      url = "#{url}#{rails_root}"
    end
    url
  end

  def self.rest_url_base(include_rails_root = true)
    url = ENV["rest_root"]
  end

  #Returns the format of the messages being tested as a symbol.  Either :json or :xml
  def self.message_format
    if !@message_format
      format = (ENV["msg_format"] or "json")
      @message_format = format.to_sym
    end
    @message_format
  end

  def self.message_format_mime_type
    if message_format == :json
      return "application/json"
    elsif message_format == :xml
      return "application/xml"
    else
      raise "Unknown message format #{message_format}"
    end
  end

  def self.decode_from_format(value)
    if message_format == :json
      ActiveSupport::JSON.decode(value)
    elsif message_format == :xml
      Hash.from_xml(value)
    else
      raise "Unknown message format #{message_format}"
    end
  end

end
