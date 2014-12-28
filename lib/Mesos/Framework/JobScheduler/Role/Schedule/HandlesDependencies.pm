package Mesos::Framework::JobScheduler::Role::Schedule::HandlesDependencies;
use Moo::Role;
with "Mesos::Framework::JobScheduler::Role::Schedule";

=head1 NAME

Mesos::Framework::JobScheduler::Role::Schedule::HandlesDependencies

=head1 METHODS

=head2 get_dependents($name)

=head2 register_dependency($job)

=head2 deregister_dependency($name)

=cut

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
    $self->register_dependency($job) if $job->does("Mesos::Framework::JobScheduler::Role::Job::HasDependency");
};

after deregister => sub {
    my ($self, $name) = @_;
    $self->deregister_dependency($name);
};


1;
