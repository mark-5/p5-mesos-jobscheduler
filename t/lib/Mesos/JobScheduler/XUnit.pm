package Mesos::JobScheduler::XUnit;
use Bread::Board;
use Scalar::Util qw(weaken);
use Test::Class::Moose;
use namespace::autoclean;

has container => (
    is      => 'ro',
    default => sub { Bread::Board::Container->new(name => 'test-app') },
    handles => ['resolve'],
);

sub BUILD {
    weaken(my $self = shift);
    container $self->container => as {

        service event_loop => (
            class => 'Mesos::JobScheduler::EventLoop',
        );

        service logger => (
            class => 'Mesos::JobScheduler::Logger',
        );

        service storage => (
            class => 'Mesos::JobScheduler::Storage',
        );

        service registry => (
            class        => 'Mesos::JobScheduler::Registry',
            dependencies => [qw(logger storage)],
        );

        service executioner => (
            class        => 'Mesos::JobScheduler::Executioner',
            dependencies => [qw(logger storage)],
        );

        service manager => (
            class        => 'Mesos::JobScheduler::Manager',
            dependencies => [qw(event_loop executioner registry)],
            parameters   => [qw(traits)],
            block        => sub {
                my $s      = shift;
                my %params = map {($_ => $s->param($_))} $s->param;
                return Mesos::JobScheduler::Manager->new_with_traits(%params);
            },
        );

        service framework => (
            class      => 'Mesos::JobScheduler::Framework',
            parameters => [qw(traits)],
            block      => sub {
                my $s       = shift;
                my $traits  = $s->param('traits');
                my $manager = $s->fetch('manager')
                                ->get(traits => $traits);
                return Mesos::JobScheduler::Framework->new(
                    manager => $manager,
                );
            },

        );

    };
}

__PACKAGE__->meta->make_immutable;
1;
