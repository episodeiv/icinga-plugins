#!/usr/bin/perl
# Author: Dennis Lichtenthaeler <dennis.lichtenthaeler@episode-iv.de>
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

use strict;
use Getopt::Long;
use lib '/usr/lib64/nagios/plugins'; ## change this to the folder containing "utils.pm"
use utils;

my $logfile = "/var/log/unbound.log";
my $help = 0;

my $result = GetOptions (
	"logfile|l=s"	=>	\$logfile,
	"help|h"	=>	\$help,
);

if ($help) {
	print qq~$0

Check unbound request statistics

 --logfile	(default $logfile)
	Use an alternative unbound logfile
 --help
	Show this

~;
	exit;
}

my($log, $statsline);
if (!-f $logfile or !open($log, "<", $logfile)) {
	print "UNKNOWN: Cannot read $logfile\n";
	exit $utils::ERRORS{'UNKNOWN'};
}

for(<$log>) {
	next if($_ !~ /server stats/ || $_ !~ /queries/);
	$statsline=$_;
}
close($log);

if($statsline =~ /(?<queries>\d+) queries.+(?<cache>\d+) answers from cache.+(?<recursions>\d+) recursions.*(?<prefetch>\d+) prefetch/) {
	print "OK: Got results|queries=$+{queries} from_cache=$+{cache} recursions=$+{recursions} prefetch=$+{prefetch}\n";
	exit $utils::ERRORS{'OK'}
}
else {
	print "UNKNOWN: Found no valid 'server stats' line in $logfile\n";
	exit $utils::ERRORS{'UNKNOWN'};
}
