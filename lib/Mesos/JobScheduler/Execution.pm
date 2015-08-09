package Mesos::JobScheduler::Execution;

use Mesos::JobScheduler::Types qw(DateTime Job);
use Mesos::JobScheduler::Utils qw(now);
use Moo;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::HasId
    Mesos::JobScheduler::Role::Immutable
);

has added => (
    is      => 'ro',
    isa     => DateTime,
    coerce  => 1,
    default => sub { now() },
);

has job => (
    is     => 'ro',
    isa    => Job,
    coerce => 1,
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
        added => $self->added,
        id    => $self->id,
        %args,
    );
};

sub TO_JSON {
    my ($self) = @_;
    return {map {
        ($_ => $self->$_)
    } qw(added id job status updated)};
}

1;
