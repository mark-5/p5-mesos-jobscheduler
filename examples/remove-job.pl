#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use LWP::UserAgent;

my %opts = (host => 'http://localhost:8080');
GetOptions(\%opts, 'host=s');

my ($id) = @ARGV or die "USAGE: $0 [OPTIONS] ID\n";

my $ua  = LWP::UserAgent->new;
my $res = $ua->delete("$opts{host}/api/job/$id?pretty=1");
print $res->decoded_content;
