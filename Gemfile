source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

gem 'activeresource', '>= 6.0'
gem 'ffi', '1.15.5'
gem 'flipper'
gem 'georuby', '~> 2.5.2'
gem 'jquery-rails'
gem 'loofah', '>= 2.3.1'
gem 'marcel'
gem 'nokogiri', '>= 1.18.9'
gem 'rack', '>= 2.2.14'
gem 'rails-controller-testing'
gem 'rails', '~> 8.0'
gem 'responders', '~> 3.0'
gem 'rest-client', '~> 2.0.2'
gem 'rgeo', '~> 1.0.0'
gem 'unicorn'
gem 'webrick'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'dartsass-sprockets'
  gem 'terser'
end

group :production, :sit, :uat do
  gem 'redis'
  gem 'rufus-scheduler'
end

group :development do
  gem 'pry-rails'
  # better error handling
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug'
  gem 'rubocop'
end

group :test, :development do
  gem 'rspec_junit_formatter', '~> 0.3.0'
  gem 'rspec-activemodel-mocks', '~> 1.0.3'
  gem 'rspec-rails'
end

group :test do
  gem 'simplecov', :require => false
  gem 'cucumber-rails', :require => false
  gem 'vcr'
  gem 'webmock'
  gem 'capybara'
  gem 'rack-test'
end
gem "connection_pool", "~> 2.4"
