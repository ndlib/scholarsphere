#!/bin/bash

# Starts the server on the dl-vecnet server. It assumes
# there is an nginx reverse proxy at port 3000 which balances
# the load between ports 3001--3006.

LISTEN_PORTS=$(echo "-l 127.0.0.1:"{3001,3002,3003,3004,3005,3006})

RAILS_ENV=dlvecnet bundle exec unicorn $LISTEN_PORTS
