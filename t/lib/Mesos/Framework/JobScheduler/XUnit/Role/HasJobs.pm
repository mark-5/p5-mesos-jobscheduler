package Mesos::Framework::JobScheduler::XUnit::Role::HasJobs;
use Types::Standard qw(HashRef ArrayRef Str);
use Time::HiRes qw(time);
use Mesos::Framework::JobScheduler::XUnit::Utils qw(executor);
use MooseX::Role::Parameterized;

parameter jobs => (
    isa      => HashRef[ ArrayRef[Str] ],
    required => 1,
);

my $count = 0;
role {
    my ($param) = @_;
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
            $class->add_attribute("+name",     default => sub { "test-" . ($$ ^ time) . ++$count });
            $class->add_attribute("+executor", default => sub { executor() });

            $class->make_immutable;
            return $class->name;
        };
    }
};


1;
