package Mesos::JobScheduler::XUnit::Utils;
use strict;
use warnings;
use Mesos::JobScheduler::Types qw(to_Job);
use base 'Exporter::Tiny';

our @EXPORT_OK = qw(new_job);

sub new_job {
    my (@args) = @_;
    my %defaults = (
        command => 'test-command-' . rand,
        name    => 'test-name-'    . rand,
    );
    if (@args % 2) {
        # map new_job($type, %args) -> new_job(type => $type, %args)
        unshift @args, 'type';
    }
    return to_Job {%defaults, @args};
}

1;
