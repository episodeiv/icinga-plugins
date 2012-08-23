#!/bin/bash
# taken from http://docs.pnp4nagios.org/de/pnp-0.4/wrapper?s=procs
LINE=`/usr/lib/nagios/plugins/check_procs $*`
RC=$?
COUNT=`echo $LINE | awk '{print $3}'`
echo $LINE \| procs=$COUNT
exit $RC
