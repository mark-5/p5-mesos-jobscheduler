package Mesos::JobScheduler::XUnit::Role::RegistryFactory;
use Mesos::JobScheduler::Logger;
use Mesos::JobScheduler::Registry;
use Mesos::JobScheduler::Storage;
use Test::Class::Moose::Role;

sub new_registry {
    my ($test, @args) = @_;
    return Mesos::JobScheduler::Registry->new(
        logger  => Mesos::JobScheduler::Logger->new,
        storage => Mesos::JobScheduler::Storage->new,
        @args,
    );
}

1;
