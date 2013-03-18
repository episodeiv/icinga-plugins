#!/usr/bin/perl

use strict;
use File::Basename;
use Cache::Memcached;
use Getopt::Long;

my $debug =		0;
my $version =		'1.1 20120322';
my $memd_host =		'localhost';
my $memd_port =		'11211';
my $memd_namespace =	'NAGIOS:';
my $memd_exp =		5;
my $w_conn =		75;
my $w_bytes =		75;
my $w_hitrate =		25;
my $c_conn =		85;
my $c_bytes =		85;
my $c_hitrate =		15;
my $maxconn =		128;
my %ERRORS =		('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);

#
# Funcions
#
sub memd_set {
	my($memd,$key,$value) = @_;

	if ( ! $memd->set($key,$value,$memd_exp) ) {
		print "ERROR: memd_set(): key='$key',value='$value',error='Memcached Set failed'\n";
		exit $ERRORS{'CRITICAL'};
	}
	print "DEBUG: memd_set(): key='$key',value='$value'\n" if ($debug);
	return 1;
}

sub memd_get {
	my($memd,$key) = @_;

	my $value = $memd->get($key);
	if ( ! $value ) {
		print "ERROR: memd_get(): key='$key',error='Memcached Get failed'\n";
		exit $ERRORS{'CRITICAL'};
	}
	print "DEBUG: memd_get(): key='$key',value='$value'\n" if ($debug);
	return $value;
}

sub memd_stats {
	my($memd) = @_;
	my %retval;

	my $tmp = $memd->stats();
	if ( ! $tmp ) {
		print "ERROR: memd_stats(): error='Memcached Stats failed'\n";
		exit $ERRORS{'CRITICAL'};
	}
	my %values = %$tmp;
	foreach my $key (keys %{ $values{'hosts'}{"$memd_host:$memd_port"}{'misc'}}) {
		$retval{$key} = $values{'hosts'}{"$memd_host:$memd_port"}{'misc'}{$key};
		print "DEBUG: memd_stats(): $key => $values{'hosts'}{\"$memd_host:$memd_port\"}{'misc'}{$key}\n" if ($debug);
	}

	return %retval;
}

sub usage () {
	my $name = basename($0);
	print <<EOD;

	$name [-h] [-d] [-H host] [-P port] [-w w_conn,w_bytes,w_hitrate] [-c c_conn,c_bytes,c_hitrate] [-m maxcon]

	-h|--help:	This Help.
	-d|--debug:	Debug messages.
	-H|--host:	Hostname. [Default: $memd_host].
	-P|--port:	Port. [Default: $memd_port].
	-m|--maxconn:	Max Connections configured in Memcached (-c). [Default: $maxconn].
	-w|--warning:	Warning thresholds percents (connections,bytes_used,hitrate). [Defaults: $w_conn,$w_bytes,$w_hitrate].
	-c|--critical:	Critical thresholds percents (connections,bytes_used,hitrate). [Defaults: $c_conn,$c_bytes,$c_hitrate].

EOD
}

sub check_options () {
	my $o_help;
	my $o_w;
	my $o_c;

	Getopt::Long::Configure ("bundling");
	GetOptions(
		'h|help'	=> \$o_help,
		'd|debug'	=> \$debug,
		'H|host:s'	=> \$memd_host,
		'P|port:i'	=> \$memd_port,
		'm|maxconn:i'	=> \$maxconn,
		'w|warning:s'	=> \$o_w,
		'c|critical:s'	=> \$o_c
	);

	if ( defined($o_help) ) {
		usage();
		exit $ERRORS{UNKNOWN};
	}
	if ( defined($o_w) ) {
		if ( $o_w =~ /^([0-9]+),([0-9]+),([0-9]+)$/ ) {
			$w_conn = $1;
			$w_bytes = $2;
			$w_hitrate = $3;
			foreach my $val ( $w_conn,$w_bytes,$w_hitrate ) {
				if ( $val < 0 or $val > 100 ) {
					usage();
					exit $ERRORS{UNKNOWN};
				}
			}
			print "DEBUG: w_conn=$w_conn,w_bytes=$w_bytes,w_hitrate=$w_hitrate\n" if ($debug);
		} else {
			usage();
			exit $ERRORS{UNKNOWN};
		}
	}
	if ( defined($o_c) ) {
		if ( $o_c =~ /^([0-9]+),([0-9]+),([0-9]+)$/ ) {
			$c_conn = $1;
			$c_bytes = $2;
			$c_hitrate = $3;
			foreach my $val ( $c_conn,$c_bytes,$c_hitrate ) {
				if ( $val < 0 or $val > 100 ) {
					usage();
					exit $ERRORS{UNKNOWN};
				}
			}
			print "DEBUG: c_conn=$c_conn,c_bytes=$c_bytes,c_hitrate=$c_hitrate\n" if ($debug);
		} else {
			usage();
			exit $ERRORS{UNKNOWN};
		}
	}
}

#
# Main
#
check_options();

my $memd = Cache::Memcached->new( {
	servers		=> [ "$memd_host:$memd_port" ],
	namespace	=> $memd_namespace,
} );

my $value = time();
memd_set($memd,"$memd_namespace:nagios",$value);
if ( memd_get($memd,"$memd_namespace:nagios") ne $value ) {
	print "ERROR: Memcached Get returns a wrong value'\n";
	exit $ERRORS{'CRITICAL'};
}
my %values = memd_stats($memd);
$memd -> disconnect_all;

my $conn = sprintf ( "%.01f", ( ($values{'curr_connections'} -1) / $maxconn ) * 100 );
my $bytes = sprintf ( "%.01f", ( $values{'bytes'} / $values{'limit_maxbytes'} ) * 100 );
my $hitrate = sprintf("%.01f", ( $values{'get_hits'} / ($values{'get_hits'} + $values{'get_misses'}) ) * 100 );
print "DEBUG: conn=$conn%,bytes=$bytes%,hitrate=$hitrate%\n" if ($debug);

my $status = 'OK';
if ( $conn > $w_conn or $bytes > $w_bytes or $hitrate < $w_hitrate ) {
	$status = 'WARNING';
	print "DEBUG: Set status to 'WARNING'\n";
}
if ( $conn > $c_conn or $bytes > $c_bytes or $hitrate < $c_hitrate ) {
	$status = 'CRITICAL';
	print "DEBUG: Set status to 'CRITICAL'\n";
}

print "Status=$status, Set/Get=OK, conn=$conn%, bytes=$bytes%, hitrate=$hitrate% | 'conn'=$conn%;$w_conn;$c_conn;0;100 'bytes'=$bytes%;$w_bytes;$c_bytes;0;100 'hitrate'=$hitrate%;$w_hitrate;$c_hitrate;0;100\n";
exit $ERRORS{$status};

