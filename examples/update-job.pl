#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use HTTP::Request;
use JSON qw(encode_json);
use LWP::UserAgent;

my %opts = (host => 'http://localhost:8080');
GetOptions(\%opts, 'host=s');

my ($id, %args) = @ARGV or die "USAGE: $0 [OPTIONS] ID ATTRIBUTE VALUE..\n";

my $req = HTTP::Request->new(
    'PATCH',
    "$opts{host}/api/job/$id?pretty=1",
    ['Content-Type' => 'application/json'],
    encode_json(\%args),
);
my $res = LWP::UserAgent->new->request($req);
print $res->decoded_content;
