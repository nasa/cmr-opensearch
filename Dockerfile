# Ruby image
FROM ruby:3.2.7

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update -qq && apt-get install -y apt-utils debian-archive-keyring
RUN apt-get install -y build-essential libpq-dev

RUN mkdir /cmr-opensearch
WORKDIR /cmr-opensearch

# Copy ruby version file
COPY .ruby-version /cmr-opensearch/.ruby-version

# Copy Gemfile
COPY Gemfile /cmr-opensearch/Gemfile

RUN gem install bundler

# Finish establishing our Ruby environment
RUN bundle config --global silence_root_warning 1
RUN bundle install

# Copy the Rails application into place
COPY . /cmr-opensearch

RUN bundle exec rake assets:precompile