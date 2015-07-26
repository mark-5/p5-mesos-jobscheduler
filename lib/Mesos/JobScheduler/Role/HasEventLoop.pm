package Mesos::JobScheduler::Role::HasEventLoop;
use AnyEvent::Future;
use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Interface::EventLoop';

sub new_timer {
    my ($self, %args) = @_;
    return AnyEvent::Future->new_delay(%args);
}

1;
