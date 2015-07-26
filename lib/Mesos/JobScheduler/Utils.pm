package Mesos::JobScheduler::Utils;
use strict;
use warnings;
use DateTime;
use base 'Exporter::Tiny';
our @EXPORT_OK = qw(now);

sub now {
    my (%args) = @_;
    return DateTime->now(time_zone => 'UTC');
}

1;
