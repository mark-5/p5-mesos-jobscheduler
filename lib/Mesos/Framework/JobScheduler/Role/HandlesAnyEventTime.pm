package Mesos::Framework::JobScheduler::Role::HandlesAnyEventTime;
use AnyEvent;
use DateTime;
use Moo::Role;

sub now { DateTime->from_epoch(epoch => AnyEvent->now) }

1;
