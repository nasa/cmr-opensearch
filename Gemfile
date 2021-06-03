source 'https://rubygems.org'

File.read(".ruby-version").chomp.split('-')[1] { |f| "ruby '#{f}'"}

gem 'rails', '5.2.4.6'
gem 'activeresource', '>= 5.1.1'
gem 'responders', '~> 2.0'
gem 'unicorn'
gem 'jquery-rails', '~> 4.3.1'
gem 'nokogiri', '>= 1.10.8'
gem 'rest-client', '~> 2.0.2'
gem 'rgeo', '~> 1.0.0'
gem 'georuby', '~> 2.5.2'
gem 'loofah', '>= 2.3.1'
gem 'rack', '~> 2.0'
gem 'ffi', '1.9.24'
gem 'rails-controller-testing'
gem 'flipper'
gem 'mimemagic', '~> 0.3.7'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 5.0.7'
  gem 'sass', '~> 3.5.5'
  gem 'coffee-rails', '~> 4.2.2'
  gem 'execjs', '~> 2.7.0'
  gem 'therubyracer', '~> 0.12.3'
  gem 'uglifier', '~> 4.1.6'
end

group :production, :sit, :uat do
  # to compensate for the CMR static tagging functionality
  gem 'rufus-scheduler'
  gem 'rails_12factor'
end

group :development do
  gem 'pry-rails'

  # better error handling
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'byebug'
end

group :test, :development do
  gem 'rspec-rails', '~> 3.7.2'
  gem 'rspec-activemodel-mocks', '~> 1.0.3'
  gem 'rspec_junit_formatter', '~> 0.3.0'
end


group :test do
  gem 'simplecov', :require => false
  gem 'cucumber-rails', :require => false
  gem 'vcr'
  gem 'webmock'
  gem 'capybara'
  gem 'rack-test'
end

gem 'bundler-audit'
