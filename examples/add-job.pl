#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use DateTime::Format::RFC3339;
use JSON qw(encode_json);
use LWP::UserAgent;
use Mesos::JobScheduler::Utils qw(now);

my %opts = (host => 'http://localhost:8080');
GetOptions(\%opts, 'host=s');

my ($cmd) = @ARGV;
$cmd //= 'echo some test job';

my $job = {
    command   => $cmd,
    name      => 'example job',
    scheduled => DateTime::Format::RFC3339->format_datetime(now()),
    type      => 'OneOff',
};

my $ua  = LWP::UserAgent->new;
my $res = $ua->post(
    "$opts{host}/api/job?pretty=1",
    'Content-Type' => 'application/json',
    'Content'      => encode_json($job),
);

print $res->decoded_content;
