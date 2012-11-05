Icinga plugins
==============

This folder/repository/thing you're looking at contains various Icinga plugins
I have collected or written over time. All my own plugins are GPL licensed,
the other plugins' licences can be seen in the respective files.

At the moment, the following plugins exist:

* **check_amavis**: Used to fetch various bits of information
   from amavisd's *snmp.db*. Includes the time the various
   components took to scan mails and the number of messages
   processed.
* **check_cpu.sh**: Uses /proc/stat to get CPU usage
* **check_entropy.sh**: Get available kernel entropy
* **check_fail2ban**: See how many users were captured
   by fail2ban jails
* **check_nginx.sh**: Extracts various bits of information
   from nginx's /nginx_status page
* **check_pid.sh**: Check if a process that created a
   pid file is still running
* **check_postfix_queue**: Count the number of mails
   stuck in the various postfix queues
* **check_procs_perf.sh**: Wrapper for *check_procs* that
   outputs the number of processes as performance data
* **check_sftp_usage**: Check fs usage via sftp (written for
   Hetzner's backup servers)
* **check_smart**: Get lots of SMART data from a disk
* **check_tor_fd.sh**: Use the number of open file descriptors
   as a crude method of finding out how many clients a tor node
   currently services
* **check_traffic.sh**: Check current traffic on ethernet interfaces.
   Does not support IPv6 yet and needs an IPTables rule.

Where applicable, the plugins produce performance data suitable
for pnp4nagios or similar tools.

Need anything? Contact me at charon+icinga@episode-iv.de
