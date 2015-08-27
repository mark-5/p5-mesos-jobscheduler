package Mesos::JobScheduler;

use Bread::Board;
use Mesos::JobScheduler::Utils qw(find_traits);
use Mesos::JobScheduler::Types qw(Config);
use Scalar::Util qw(weaken);
use Moose;
use namespace::autoclean;
extends 'Bread::Board::Container';

# ABSTRACT: services for building Mesos job scheduling frameworks

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

        service config => $self->config;

        service event_loop => (
            class     => 'Mesos::JobScheduler::EventLoop',
            lifecycle => 'Singleton',
        );

        service logger => (
            class     => 'Mesos::JobScheduler::Logger::STDERR',
            lifecycle => 'Singleton',
        );

        service storage => (
            class        => 'Mesos::JobScheduler::Storage::ZooKeeper',
            lifecycle    => 'Singleton',
            dependencies => {zk => 'zookeeper'},
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
            dependencies => [qw(config framework logger manager mesos)],
            block        => sub {
                my $s      = shift;
                my %params = map {($_ => $s->param($_))} $s->param;
                my @traits = find_traits('Mesos::JobScheduler::API');
                return Mesos::JobScheduler::API->new_with_traits(
                    traits => \@traits,
                    %params,
                );
            },
        );

        service mesos => (
            class        => 'Mesos::SchedulerDriver',
            lifecycle    => 'Singleton',
            dependencies => [qw(config event_loop framework)],
            block        => sub {
                my $s         = shift;
                my $conf      = $s->param('config')->mesos;
                my $framework = $s->param('framework');
                my $loop      = $s->param('event_loop');
                return Mesos::SchedulerDriver->new(
                    dispatcher => $loop->type,
                    framework  => {
                        user => $conf->{user} // '',
                        name => 'Mesos::JobScheduler Framework',
                    },
                    master    => $conf->{master},
                    scheduler => $framework,
                );
            },
        );

        service zookeeper => (
            class        => 'ZooKeeper',
            lifecycle    => 'Singleton',
            dependencies => [qw(config event_loop)],
            block        => sub {
                my $s    = shift;
                my $conf = $s->param('config')->zookeeper;
                my $loop = $s->param('event_loop');
                return ZooKeeper->new(
                    dispatcher => $loop->type,
                    hosts      => $conf->{hosts},
                );
            },
        );

    };
}

__PACKAGE__->meta->make_immutable;
1;
