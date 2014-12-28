package Mesos::JobScheduler::Role::HandlesAnyEventTime;
use AnyEvent;
use DateTime;
use Moo::Role;

=head1 NAME

Mesos::JobScheduler::Role::HandlesAnyEventTime

=head1 METHODS

=head2 now()

=cut

sub now { DateTime->from_epoch(epoch => AnyEvent->now) }

1;
