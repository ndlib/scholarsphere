#!/bin/sh

# Using iptables to reroute ports is all over the internet.
# I used http://blog.softlayer.com/2011/iptables-tips-and-tricks-port-redirection/

iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 3000
