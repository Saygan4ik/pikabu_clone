#!/bin/bash

bundle check || bundle install

sidekiq -C config/sidekiq.yml
