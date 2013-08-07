#!/bin/bash

. /usr/lib/nagios/plugins/utils.sh

host=""
warning=""
critical=""

while getopts h:w:c: name
do
	case $name in
		h)	host="$OPTARG";;
		w)	warning="$OPTARG";;
		c)	critical="$OPTARG";;
	esac
done

if [ -z ${host} ]; then
	echo "Usage: $0 -h HOSTNAME [-w bytes] [-c bytes]"
	exit $STATE_UNKNOWN
fi

testfilename=$(tempfile)
echo "exit" > ${testfilename}

sftpCheck=$(sftp -b ${testfilename} ${host});
sftpCheckResult=$?
rm ${testfilename}

if [ ${sftpCheckResult} -gt 0 ]; then
	echo "Error while connecting to ${host}"
	exit $STATE_UNKNOWN
fi

usagePercent=$(echo df | sftp -q ${host} 2> /dev/null| tail -n1 | awk '{ print $5 }')
usagePercent=${usagePercent%?}


if [ ! -z ${critical} ]; then
	if [[ ${usagePercent} -gt ${critical} ]]; then
		echo "CRITICAL: ${usagePercent}% used|usage=${usagePercent}%"
		exit $STATE_CRITICAL
	fi
fi

if [ ! -z ${warning} ]; then
	if [[ ${usagePercent} -gt ${warning} ]]; then
		echo "WARNING: ${usagePercent}% used|usage=${usagePercent}%"
		exit $STATE_WARNING
	fi
fi

echo "OK: ${usagePercent}% used|usage=${usagePercent}%"
exit $STATE_OK

