#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use DateTime;
use DateTime::Format::RFC3339;
use JSON qw(encode_json);
use LWP::UserAgent;

my %opts = (host => 'http://localhost:8080');
GetOptions(\%opts, 'host=s');

my ($cmd) = @ARGV;
$cmd //= 'echo some test job';

my $now = DateTime::Format::RFC3339->format_datetime(
    DateTime->now(time_zone => 'UTC'),
);
my $job = {
    command   => $cmd,
    name      => 'example job',
    scheduled => $now,
    type      => 'OneOff',
};

my $ua  = LWP::UserAgent->new;
my $res = $ua->post(
    "$opts{host}/api/job?pretty=1",
    'Content-Type' => 'application/json',
    'Content'      => encode_json($job),
);

print $res->decoded_content;
