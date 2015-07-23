package Mesos::JobScheduler::Job;
use Types::UUID qw(Uuid);
use Moo;
use namespace::autoclean;
with qw(
    MooX::Rebuild
    Mesos::JobScheduler::Role::HasId
);

has name => (
    is       => 'ro',
    required => 1,
);

has command => (
    is       => 'ro',
    required => 1,
);

sub update {
    my ($self, %args) = @_;
    # don't generate a new id
    return $self->rebuild(id => $self->id, %args);
}

1;
