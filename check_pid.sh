#!/bin/bash
# Author: Dennis Lichtenthaeler <dennis.lichtenthaeler@episode-iv.de>

. /usr/lib/nagios/plugins/utils.sh

if [ -z $1 ]; then
	echo "Usage: $0 /path/to/file.pid"
	exit $STATE_UNKNOWN
fi


if [ ! -e $1 ]; then
	echo "CRITICAL: File $1 does not exist"
	exit $STATE_CRITICAL
fi

pid=$(<$1)

echo $pid

if [ -z $pid ]; then
	echo "CRITICAL: Unable to read pid file"
	exit $STATE_CRITICAL
fi

if [ -d /proc/$pid ]; then
	echo "OK: Process running with PID ${pid}"
	exit $STATE_OK
else
	echo "CRITICAL: Process not running"
	exit $STATE_CRITICAL
fi

