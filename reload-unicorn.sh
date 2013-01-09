#!/bin/bash

if [ ! -e unicorn.pid ]; then
	exit "Cannot find unicorn.pid"
fi

PID=$(cat unicorn.pid)

# does process exist?
if kill -0 $PID; then
	echo "Signaling server at pid=$PID"
	kill -USR2 $PID
	sleep 10
	echo "Killing old server"
	kill -QUIT $PID
else
	echo "Process ID in unicorn.pid does not exist"
fi

