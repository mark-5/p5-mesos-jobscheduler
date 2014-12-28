package Mesos::Framework::JobScheduler::Role::Job::HasTimer;
use Carp;
use Types::DateTime qw(DateTimeUTC Format);
use Moo::Role;
with qw(
    Mesos::Framework::JobScheduler::Role::HandlesAnyEventTime
    Mesos::Framework::JobScheduler::Role::Job
);

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
    my ($self, $until, $from) = @_;
    my $scheduled = $self->scheduled_time;
    return $scheduled unless $scheduled <= $until and $scheduled >= $from;
}

1;
