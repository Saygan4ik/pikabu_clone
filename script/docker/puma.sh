#!/bin/bash

bundle check || bundle install

bundle exec puma -p 3000
