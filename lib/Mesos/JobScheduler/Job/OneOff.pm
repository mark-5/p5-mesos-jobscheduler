package Mesos::JobScheduler::Job::OneOff;
use DateTime::Format::RFC3339;
use Types::DateTime qw(DateTimeUTC Format);
use Moo;
use Mesos::JobScheduler::Utils qw(now);
extends 'Mesos::JobScheduler::Job';
use namespace::autoclean;

=head1 ATTRIBUTES

=head2 scheduled

=cut

has scheduled => (
    is      => 'ro',
    isa     => DateTimeUTC->plus_coercions(Format['RFC3339']),
    coerce  => 1,
    default => sub { now() },
);

around TO_JSON => sub {
    my ($orig, $self) = @_;
    my $object = $self->$orig;
    $object->{scheduled} = DateTime::Format::RFC3339->format_datetime($self->scheduled);
    return $object;
};

1;
