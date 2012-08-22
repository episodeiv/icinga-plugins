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

pidfile=/var/run/tor/tor.pid

if [ $1 ]; then
	pidfile=$1
fi

if [ ! -f $1 ]; then
	echo "UNKNOWN: ${pidfile} is not readable"
	exit $STATE_UNKNOWN
fi

pid=$(<${pidfile})

if [ ! -d /proc/${pid}/fd ]; then
	echo "UNKNOWN: Cannot find fds for process"
	exit $STATE_UNKNOWN
fi

fdcount=`ls /proc/${pid}/fd | wc -l`

echo "OK: ${fdcount} connections|fdconnections=${fdcount}"
exit $STATE_OK
