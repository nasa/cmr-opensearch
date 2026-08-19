EchoOpensearch::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.enable_reloading = false

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  config.public_file_server.enabled = true
  config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.relative_url_root = ''

  config.graphql_endpoint = ENV['GRAPHQL_ENDPOINT']
  # config.cache_store = :memory_store, { size: 64.megabytes }
  config.cache_store = :null_store

  config.holdings_providers = [
    { 'provider' => 'TEST', 'params' => { 'dataCenter' => 'test' } }
  ]

  Rails.logger = Logger.new("#{Rails.root}/log/#{Rails.env}.log")
  Rails.logger.formatter = Logger::Formatter.new

  puts 'This is a test deployment'
end
