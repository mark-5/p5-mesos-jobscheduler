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
    coerce  => 1,
    default => sub { {} },
);

has framework => (
    is       => 'ro',
    required => 1,
);

has logger => (
    is       => 'ro',
    required => 1,
);

has manager => (
    is       => 'ro',
    required => 1,
);

has mesos => (
    is       => 'ro',
    required => 1,
    handles  => [qw(run start stop wait)],
);

sub BUILD {
    my ($self) = @_;
    $self->start;
}

sub DEMOLISH {
    my ($self) = @_;
    $self->stop;
}

__PACKAGE__->meta->make_immutable;
1;
