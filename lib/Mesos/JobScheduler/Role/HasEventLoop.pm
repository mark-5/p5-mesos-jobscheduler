package Mesos::JobScheduler::Role::HasEventLoop;
use AnyEvent::Future;
use Moo::Role;
use namespace::autoclean;

sub new_timer {
    my ($self, %args) = @_;
    return AnyEvent::Future->new_delay(%args);
}

1;
