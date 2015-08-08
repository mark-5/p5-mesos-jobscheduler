package Mesos::JobScheduler::Job::OneOff;

use Mesos::JobScheduler::Types qw(DateTime);
use Mesos::JobScheduler::Utils qw(now);
use Moo;
use namespace::autoclean;
extends 'Mesos::JobScheduler::Job';

=head1 ATTRIBUTES

=head2 scheduled

=cut

has scheduled => (
    is      => 'ro',
    isa     => DateTime,
    coerce  => 1,
    default => sub { now() },
);

around TO_JSON => sub {
    my ($orig, $self) = @_;
    my $object = $self->$orig;
    $object->{scheduled} = $self->scheduled;
    return $object;
};

1;
