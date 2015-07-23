package Mesos::JobScheduler::Role::HasId;
use Types::UUID qw(Uuid);
use Moo::Role;
use namespace::autoclean;

has id => (
    is      => 'ro',
    lazy    => 1,
    default => Uuid->generator,
);

1;
