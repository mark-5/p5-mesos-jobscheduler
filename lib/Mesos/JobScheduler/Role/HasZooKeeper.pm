package Mesos::JobScheduler::Role::HasZooKeeper;

use List::MoreUtils qw(any);
use Types::Standard qw(HashRef InstanceOf);
use ZooKeeper;
use Moo::Role;
use namespace::autoclean;

has zk => (
    is  => 'ro',
    isa => InstanceOf->of('ZooKeeper')->plus_coercions(
        HashRef() => sub { ZooKeeper->new($_) },
    ),
    coerce => 1,
    lazy   => 1,
);

1;
