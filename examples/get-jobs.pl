#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use LWP::Simple qw(getprint);

my %opts = (host => 'http://localhost:8080');
GetOptions(\%opts, 'host=s');

getprint("$opts{host}/api/jobs?pretty=1");
