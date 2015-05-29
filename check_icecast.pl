#!/usr/bin/perl

use strict;
use LWP::Simple;
use JSON;
use Nagios::Plugin;

my $plugin = Nagios::Plugin->new(
	usage => "Usage: %s -H <host> -p <port>",
	timeout => 30,
);

$plugin->add_arg(
	spec => 'host|H=s',
	help => "Icecast host",
	required => 1,
);

$plugin->add_arg(
	spec => 'port|p=i',
	help => "Icecast port",
	required => 1,
);

$plugin->getopts;

## get status-json.xsl
my $url = "http://" . $plugin->opts->host . ":" . $plugin->opts->port . "/status-json.xsl";
my $content = get($url) or $plugin->nagios_exit('UNKNOWN', "Unable to check status: $!");

## strange fixup...
$content =~ s/,\}/\}\}/g;

## decode JSON
my $json = JSON->new->utf8;
my $icecast = $json->decode($content) or $plugin->nagios_exit('UNKNOWN', "Unable to decode JSON data: $!");

my $streaming = defined($icecast->{icestats}->{source}) ? "Streaming" : "Not streaming";
my $listeners = $icecast->{icestats}->{source}->{listeners} || 0;

$plugin->add_perfdata(
	label => 'listeners',
	value => $listeners,
);

$plugin->nagios_exit(OK, $streaming.", current listeners: ".$listeners);
