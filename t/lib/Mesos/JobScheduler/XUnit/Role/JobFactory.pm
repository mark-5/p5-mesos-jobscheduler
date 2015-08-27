package Mesos::JobScheduler::XUnit::Role::JobFactory;
use Mesos::JobScheduler::Types qw(to_Job);
use Test::Class::Moose::Role;
use namespace::autoclean;

sub new_job {
    my ($test, @args) = @_;
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
