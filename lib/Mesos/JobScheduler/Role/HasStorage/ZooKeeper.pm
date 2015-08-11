package Mesos::JobScheduler::Role::HasStorage::ZooKeeper;

use Mesos::JobScheduler::Storage::ZooKeeper;
use Moo::Role;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::HasStorage
    Mesos::JobScheduler::Role::HasZooKeeper
);

around build_storage => sub {
    my (undef, $self) = @_;
    return Mesos::JobScheduler::Storage::ZooKeeper->new(
        zk => $self->zk,
    );
};

1;
