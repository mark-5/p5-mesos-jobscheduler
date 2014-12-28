package Mesos::Framework::JobScheduler::XUnit::Role::HasSchedules;
use Types::Standard qw(HashRef ArrayRef Str);
use MooseX::Role::Parameterized;

parameter schedules => (
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
};

1;
