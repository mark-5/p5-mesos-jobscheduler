package Mesos::JobScheduler::EventLoop;

use AnyEvent::Future;
use Moose;
use namespace::autoclean;

has type => (
    is      => 'ro',
    default => 'AnyEvent',
);

sub new_timer {
    my ($self, %args) = @_;
    return AnyEvent::Future->new_delay(%args);
}

__PACKAGE__->meta->make_immutable;
1;
