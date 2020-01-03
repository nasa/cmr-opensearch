source 'https://rubygems.org'

ruby File.read(".ruby-version").chomp.split('-')[1] { |f| "ruby '#{f}'"}

gem 'rails', '6.0.2.1'
gem 'activeresource', '~> 5.1.0'
gem 'responders', '~> 3.0'
gem 'unicorn'
gem 'jquery-rails', '~> 4.3.5'
gem 'nokogiri', '>= 1.10.5'
gem 'rest-client', '~> 2.0.2'
gem 'rgeo', '~> 1.0.0'
gem 'georuby', '~> 2.5.2'
gem 'loofah', '>= 2.3.1'
gem 'rack', '~> 2.0.8'
gem 'ffi', '1.9.24'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 6.0.0'
  gem 'sass', '~> 3.5.5'
  gem 'coffee-rails', '~> 5.0.0'
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
end

group :test, :development do
  gem 'rspec-rails', '~> 3.9.0'
  gem 'rspec-activemodel-mocks', '~> 1.1.0'
  gem 'rspec_junit_formatter', '~> 0.3.0'
end


group :test do
  gem 'cucumber-rails', :require => false
  gem 'vcr'
  gem 'webmock'
  gem 'capybara'
  gem 'rack-test'
end

gem 'bundler-audit'
