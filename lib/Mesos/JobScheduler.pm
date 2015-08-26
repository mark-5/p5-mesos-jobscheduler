package Mesos::JobScheduler;

use Bread::Board;
use Mesos::JobScheduler::Utils qw(find_traits);
use Mesos::JobScheduler::Types qw(Config);
use Scalar::Util qw(weaken);
use Moose;
use namespace::autoclean;
extends 'Bread::Board::Container';

# ABSTRACT: a base class for Mesos job scheduling frameworks

has '+name' => (
    default => 'app',
);

has config => (
    is      => 'ro',
    isa     => Config,
    coerce  => 1,
    default => sub { {} },
);

sub BUILD {
    weaken(my $self = shift);
    container $self => as {

        service config => literal($self->config);

        service event_loop => (
            class        => 'Mesos::JobScheduler::EventLoop',
            lifecycle    => 'Singleton',
            dependencies => [qw(config)],
        );

        service logger => (
            class        => 'Mesos::JobScheduler::Logger',
            lifecycle    => 'Singleton',
            dependencies => [qw(config)],
        );

        service storage => (
            class        => 'Mesos::JobScheduler::Storage',
            lifecycle    => 'Singleton',
            dependencies => [qw(config)],
        );

        service registry => (
            class        => 'Mesos::JobScheduler::Registry',
            lifecycle    => 'Singleton',
            dependencies => [qw(logger storage)],
        );

        service executioner => (
            class        => 'Mesos::JobScheduler::Executioner',
            lifecycle    => 'Singleton',
            dependencies => [qw(logger storage)],
        );

        service manager => (
            class        => 'Mesos::JobScheduler::Manager',
            lifecycle    => 'Singleton',
            dependencies => [qw(event_loop executioner registry)],
            block        => sub {
                my $s      = shift;
                my %params = map {($_ => $s->param($_))} $s->param;
                my @traits = find_traits('Mesos::JobScheduler::Manager');
                return Mesos::JobScheduler::Manager->new_with_traits(
                    traits => \@traits,
                    %params,
                );
            },
        );

        service framework => (
            class        => 'Mesos::JobScheduler::Framework',
            lifecycle    => 'Singleton',
            dependencies => [qw(manager)],
        );

        service api => (
            class        => 'Mesos::JobScheduler::API',
            lifecycle    => 'Singleton',
            dependencies => [qw(config logger framework manager)],
        );

    };
}

__PACKAGE__->meta->make_immutable;
1;
