package Mesos::Framework::JobScheduler::XUnit::Role::HandlesJobScheduling;
use Types::Standard qw(HashRef ArrayRef Str);
use Time::HiRes qw(time);
use Mesos::Framework::JobScheduler::XUnit::Utils qw(executor);
use MooseX::Role::Parameterized;

our $COUNT;


parameter schedules => (
    isa      => HashRef[ ArrayRef[Str] ],
    required => 1,
);

parameter jobs => (
    isa      => HashRef[ ArrayRef[Str] ],
    required => 1,
);

role {
    my ($param) = @_;

    my $schedules = $param->schedules;
    while (my ($name, $roles) = each %$schedules) {
        has $name => (
            is      => "ro",
            does    => "Mesos::Framework::JobScheduler::Role::Schedule",
            builder => "_build_$name",
        );
        method "_build_$name" => sub {
            my $class = Moose::Meta::Class->create_anon_class(
                superclasses => [qw(Moose::Object)],
                roles        => [map {/::/ ? $_ : "Mesos::Framework::JobScheduler::Role::Schedule::$_"} @$roles],
                cache        => 1,
            );
            $class->make_immutable;
            return $class->name;
        };
    }

    my $jobs = $param->jobs;
    while (my ($name, $roles) = each %$jobs) {
        has $name => (
            is      => "ro",
            does    => "Mesos::Framework::JobScheduler::Role::Job",
            builder => "_build_$name",
        );
        method "_build_$name" => sub {
            my $class = Moose::Meta::Class->create_anon_class(
                superclasses => [qw(Moose::Object)],
                roles        => [map {/::/ ? $_ : "Mesos::Framework::JobScheduler::Role::Job::$_"} @$roles],
                cache        => 1,
            );
            # caching may return an immutable anon class with defaults already set
            $class->add_attribute("+name",     default => sub { "test-" . ($$ ^ time) . ++$COUNT })
                unless $class->get_attribute("name")->has_default;
            $class->add_attribute("+executor", default => sub { executor() })
                unless $class->get_attribute("executor")->has_default;

            $class->make_immutable;
            return $class->name;
        };
    }
};


1;
