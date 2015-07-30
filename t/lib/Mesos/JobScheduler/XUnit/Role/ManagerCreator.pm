package Mesos::JobScheduler::XUnit::Role::ManagerCreator;
use Moose::Meta::Class;
use Test::Class::Moose::Role;
use namespace::autoclean;

sub new_manager {
    my ($test, @roles) = @_;
    my @defaults  = qw(
        Mesos::JobScheduler::Role::Executioner
        Mesos::JobScheduler::Role::HasEventLoop
        Mesos::JobScheduler::Role::HasTimers
        Mesos::JobScheduler::Role::Registrar
    );

    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [qw(Moose::Object)],
        roles        => [
            @defaults,
            map "Mesos::JobScheduler::Role::Manager::$_", @roles,
        ],
        cache => 1,
    );
    return $metaclass->new_object;
}

1;
