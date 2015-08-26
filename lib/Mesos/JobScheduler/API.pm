package Mesos::JobScheduler::API;

use Mesos::JobScheduler::Types qw(Config);
use Moose;
use namespace::autoclean;
with 'MooseX::Traits::Pluggable';

has '+_trait_namespace' => (
    default => '+Listener',
);

has config => (
    is      => 'ro',
    isa     => Config['api'],
    default => sub { {} },
);

has event_loop => (
    is       => 'ro',
    required => 1,
);

has framework => (
    is       => 'ro',
    required => 1,
);

has manager => (
    is       => 'ro',
    required => 1,
);

sub start_listeners {}

sub stop_listeners {}

sub BUILD {
    my ($self) = @_;
    $self->start_listeners;
}

sub DEMOLISH {
    my ($self) = @_;
    $self->stop_listeners;
}

__PACKAGE__->meta->make_immutable;
1;
