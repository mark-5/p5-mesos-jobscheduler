package Mesos::JobScheduler::Execution;

use Mesos::JobScheduler::Types qw(DateTime Job);
use Mesos::JobScheduler::Utils qw(now);
use Moose;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::HasId
    Mesos::JobScheduler::Role::Immutable
);

has created => (
    is      => 'ro',
    isa     => DateTime,
    coerce  => 1,
    default => sub { now() },
);

has job => (
    is      => 'ro',
    isa     => Job,
    coerce  => 1,
    handles => {
        job_id => 'id',
        type   => 'type',
    },
);

has status => (
    is       => 'ro',
    required => 1,
);

has updated => (
    is      => 'ro',
    isa     => DateTime,
    coerce  => 1,
    default => sub { now() },
);

around update => sub {
    my ($orig, $self, %args) = @_;
    return $self->$orig(
        created => $self->created,
        id      => $self->id,
        %args,
    );
};

sub TO_JSON {
    my ($self) = @_;
    return {map {
        ($_ => $self->$_)
    } qw(created id job status updated)};
}

__PACKAGE__->meta->make_immutable;
1;

