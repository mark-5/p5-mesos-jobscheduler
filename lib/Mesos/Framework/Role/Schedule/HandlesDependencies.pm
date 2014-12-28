package Mesos::Framework::Role::Schedule::HandlesDependencies;
use Moo::Role;
with "Mesos::Framework::Role::Schedule";


has dependencies => (
    is      => "ro",
    default => sub { {} },
);


sub get_dependents {
    my ($self, $name) = @_;
    return keys %{$self->dependencies->{$name}};
}

sub register_dependency {
    my ($self, $job) = @_;
    $self->dependencies->{$job->dependency}{$job->name} = 1;
}

sub deregister_dependency {
    my ($self, $name) = @_;
    delete $_->{$name} for values %{$self->dependencies};
}

after register => sub {
    my ($self, $job) = @_;
    $self->register_dependency($job) if $job->does("Mesos::Framework::Role::Job::HasDependency");
};

after deregister => sub {
    my ($self, $name) = @_;
    $self->deregister_dependency($name);
};


1;
