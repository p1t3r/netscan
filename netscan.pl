#!/usr/bin/perl

	#==================================================================#
	#								   #
	#  Checks if on each host in a given network a given port is open  #
	#					            		   #
	#==================================================================#


use v5.20;
use strict;
use IO::Socket::INET;
use Net::CIDR;
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure ('bundling');



# Variables
my $socket;			# Stores socket
my $proto;			# Stores protocol
my $network; 			# Stores network definition
my @ipblock;			# Stores ip addresses
my @ports; 			# Stores list of ports 


# Subroutine "usage" - prints instructions
sub usage_sub {
	return "Usage:\t$0 --net <network/mask> --port <port> --proto <protocol>\n";
}


# Subroutine "ip_sub" - transforms ip range into ip list & remove network and broadcast addr
sub ip_sub {
	if ($network =~ m/(^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$)/) {
		@ipblock = $network;
	} elsif ($network =~ m/(^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$)/) {
		@ipblock = Net::CIDR::cidr2octets($network);
		pop @ipblock;
		shift @ipblock;
	} else {print "IP address is not valid!\n";}
}


# Subroutine "execute" - executes the main algorithm
sub execute_sub {
	foreach my $host (@ipblock) {
		foreach my $port (@ports) {
			if ($socket = IO::Socket::INET->new(
				PeerHost => $host,
				PeerPort => $port,
				Proto => $proto,
				Timeout => 3,
				Reuse => 1
				)) {print "Socket $proto $host:$port is open!\n";} else {print "Socket $proto $host:$port is closed!\n";}
		}
	}
}


# Get options from command line and assign them to each variable
GetOptions(
	'net=s' => \$network,
	'port=s' => \@ports,
	'proto=s' => \$proto
) or die &usage;


# Test if all options were passed to the script
if (defined $network && @ports && defined $proto) {
	&ip_sub;
	&execute_sub;

} else {
	print &usage_sub;
}
