#!/bin/bash

# This script is the entry point for Docker. It starts up Unicron and Nginx.

cd /var/www/simple-app
bundle exec unicorn -c config/unicorn.rb -E production -D

# call nginx here later
nginx
