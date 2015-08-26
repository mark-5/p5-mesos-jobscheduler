#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use LWP::Simple qw(getprint);

my %opts = (host => 'http://localhost:8080');
GetOptions(\%opts, 'host=s');

my ($id) = @ARGV or die "USAGE: $0 [OPTIONS] ID\n";
getprint("$opts{host}/api/job/$id?pretty=1");
