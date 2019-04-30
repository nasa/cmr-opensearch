FROM ruby:2.5.3
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y apt-utils debian-archive-keyring
RUN apt-key update
RUN apt-get install -y build-essential libpq-dev
RUN mkdir /cmr-opensearch
WORKDIR /cmr-opensearch
ADD Gemfile /cmr-opensearch/Gemfile
ADD Gemfile.lock /cmr-opensearch/Gemfile.lock
RUN echo "ruby-2.5.3" > /cmr-opensearch/.ruby-version
RUN bundle config --global silence_root_warning 1
RUN bundle install
ADD . /cmr-opensearch
