#!/bin/bash

# Starts the resque pool on the dl-vecnet server. It assumes
# there is an nginx reverse proxy at port 80.

RAILS_ENV=dlvecnet bundle exec resque-pool -E dlvecnet
