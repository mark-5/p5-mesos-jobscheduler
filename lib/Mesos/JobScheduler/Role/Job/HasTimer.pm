package Mesos::JobScheduler::Role::Job::HasTimer;
use Carp;
use Types::DateTime qw(DateTimeUTC Format);
use Moo::Role;
with qw(
    Mesos::JobScheduler::Role::HandlesAnyEventTime
    Mesos::JobScheduler::Role::Job
);

=head1 NAME

Mesos::JobScheduler::Role::Job::HasTimer

=head1 ATTRIBUTES

=head2 scheduled_time

=head1 METHODS

=head2 executions()

=cut

has scheduled_time => (
    is       => "rw",
    required => 1,
    builder  => 1,
    lazy     => 1,
    isa      => DateTimeUTC->plus_coercions( Format['ISO8601'] ),
    coerce   => 1,
);

sub _build_scheduled_time { croak "Missing required arguments: scheduled_time" }

sub executions {
    my ($self, %args) = @_;
    my ($from, $until) = @args{qw(from until)};
    $from ||= $self->now;

    my $scheduled = $self->scheduled_time;
    my $is_between = ($from <= $scheduled and $scheduled <= $until);
    return $is_between ? $scheduled : ();
}

1;
