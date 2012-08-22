#!/bin/bash
# Author: Dennis Lichtenthaeler <dennis.lichtenthaeler@episode-iv.de>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

