source 'https://rubygems.org'

ruby File.read(".ruby-version").chomp.split('-')[1] { |f| "ruby '#{f}'"}

gem 'rails', '3.2.22.5'

gem 'unicorn'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3'

#gem 'jruby-openssl', '~> 0.9.10'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'execjs'

  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails', '~> 3.1.3'
gem 'nokogiri', '1.8.1'

gem 'rest-client', '~> 1.8.0'

gem 'rgeo'

gem 'georuby'

group :production, :sit, :uat do
  # to compensate for the CMR static tagging functionality
  gem 'rufus-scheduler'
  gem 'rails_12factor'
end

group :development do
  gem 'pry-rails'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'rspec_junit_formatter'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
#gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
#gem 'debugger'

group :test do
  gem 'cucumber-rails', :require => false
  gem 'vcr'
  gem 'webmock'
  gem 'capybara'
  gem 'rack-test'
end

gem 'bundler-audit'
