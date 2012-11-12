#!/bin/sh

# This assumes the 80 --> 3000 redirect is the first PREROUTING rule
# see: http://stackoverflow.com/questions/8239047/iptables-how-to-delete-postrouting-rule

iptables -t nat -D PREROUTING 1
