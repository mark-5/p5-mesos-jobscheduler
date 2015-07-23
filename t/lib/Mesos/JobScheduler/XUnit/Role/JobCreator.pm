package Mesos::JobScheduler::XUnit::Role::JobCreator;
use Mesos::JobScheduler::Job;
use Test::Class::Moose::Role;
use namespace::autoclean;

sub new_job {
    my ($test, @args) = @_;
    return Mesos::JobScheduler::Job->new(
        command => "test_command_" . rand,
        name    => "test_name_"    . rand,
        @args,
    );
}

1;
