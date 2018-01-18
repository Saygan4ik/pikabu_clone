FROM ruby:2.4.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /pikabu_clone
WORKDIR /pikabu_clone
COPY Gemfile /pikabu_clone/Gemfile
COPY Gemfile.lock /pikabu_clone/Gemfile.lock
RUN bundle install
COPY . /pikabu_clone
