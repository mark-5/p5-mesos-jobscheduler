package Mesos::JobScheduler::Role::HasStorage;

use Mesos::JobScheduler::Storage;
use Types::Standard qw(ConsumerOf);
use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::HasBUILD';

has storage => (
    is      => 'ro',
    isa     => ConsumerOf['Mesos::JobScheduler::Role::Interface::Storage'],
    lazy    => 1,
    builder => 'build_storage',
);

sub build_storage { Mesos::JobScheduler::Storage->new }

1;
