package Mesos::JobScheduler::XUnit::Role::ExecutionerFactory;
use Mesos::JobScheduler::Executioner;
use Mesos::JobScheduler::Logger;
use Mesos::JobScheduler::Storage;
use Test::Class::Moose::Role;

sub new_executioner {
    my ($test, @args) = @_;
    return Mesos::JobScheduler::Executioner->new(
        logger  => Mesos::JobScheduler::Logger->new,
        storage => Mesos::JobScheduler::Storage->new,
        @args,
    );
}

1;
