package Mesos::Framework::XUnit::Dependencies;
use Test::Class::Moose;

with "Mesos::Framework::XUnit::Role::HasSchedules" => {
    schedules => {
        schedule => ["UsesHashStorage", "HandlesDependencies"]
    },
};
with "Mesos::Framework::XUnit::Role::HasJobs" => {
    jobs => {
        normal_job    => ["Mesos::Framework::Role::Job"],
        dependent_job => ["HasDependency"],
    },
};


sub test_dependents {
    my ($self) = @_;
    my $schedule = $self->schedule->new;
    my $parent   = $self->normal_job->new;
    my $child    = $self->dependent_job->new(dependency => $parent->name);
    my $unrelated = $self->normal_job->new;

    $schedule->register($_) for $parent, $child, $unrelated;
    ok !scalar($schedule->get_dependents($unrelated->name)), "unrelated job has no dependents";
    ok !scalar($schedule->get_dependents($child->name)), "child job has no dependents";
    is +($schedule->get_dependents($parent->name))[0], $child->name, "parent job has child job dependent";
}

1;
