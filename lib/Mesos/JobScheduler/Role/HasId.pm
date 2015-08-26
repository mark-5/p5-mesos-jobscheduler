package Mesos::JobScheduler::Role::HasId;

use Types::UUID qw(Uuid);
use UUID::Tiny qw(:std);
use Moose::Role;
use namespace::autoclean;

has id => (
    is      => 'ro',
    isa     => Uuid,
    default => Uuid->generator(UUID_RANDOM),
);

1;
