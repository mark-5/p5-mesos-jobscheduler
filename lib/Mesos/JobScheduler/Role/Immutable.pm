package Mesos::JobScheduler::Role::Immutable;

use Moo::Role;
use namespace::autoclean;
with 'MooX::Rebuild';

sub update {
    my ($self, %args) = @_;
    return $self->rebuild(%args);
}

1;
