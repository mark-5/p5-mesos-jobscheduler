package Mesos::Framework::Role::HandlesAnyEventTime;
use AnyEvent;
use DateTime;
use Moo::Role;

sub now { DateTime->from_epoch(epoch => AnyEvent->now) }

1;
