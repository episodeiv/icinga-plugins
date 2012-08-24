#!/bin/bash

. /usr/lib/nagios/plugins/utils.sh

ip=""
warning=""
critical=""

while getopts i:w:c: name
do
	case $name in
		i)	ip="$OPTARG";;
		w)	warning="$OPTARG";;
		c)	critical="$OPTARG";;
	esac
done

if [ -z ${ip} ]; then
	echo "Usage: $0 -i IP-ADDRESS [-w bytes] [-c bytes]"
	exit $STATE_UNKNOWN
fi


in=$(iptables -L INPUT -v -n -x | awk '{ print $2 " " $8 }' | grep ${ip} | awk '{ print $1}')
out=$(iptables -L OUTPUT -v -n -x | awk '{ print $2 " " $7 }' | grep ${ip} | awk '{ print $1}')



if [ ! -z ${critical} ]; then
	if [[ ${in} -gt ${critical} || ${out} -gt ${critical} ]]; then
		echo "CRITICAL: Traffic for ${ip} in ${in}, traffic out ${out}|in=${in}c out=${out}c"
		exit $STATE_CRITICAL
	fi
fi

if [ ! -z ${warning} ]; then
	if [[ ${in} -gt ${warning} || ${out} -gt ${warning} ]]; then
		echo "WARNING: Traffic for ${ip} in ${in}, traffic out ${out}|in=${in}c out=${out}c"
		exit $STATE_WARNING
	fi
fi

echo "OK: Traffic for ${ip} in ${in}, traffic out ${out}|in=${in}c out=${out}c"
exit $STATE_OK

