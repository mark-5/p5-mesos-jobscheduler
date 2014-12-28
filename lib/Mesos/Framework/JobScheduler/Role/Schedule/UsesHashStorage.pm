package Mesos::Framework::JobScheduler::Role::Schedule::UsesHashStorage;
use Carp;
use Moo::Role;
with "Mesos::Framework::JobScheduler::Role::Schedule";

has _elements => (
    is      => "ro",
    default => sub { {} },
);

sub all { values %{shift->_elements} }

sub get {
    my ($self, $name) = @_;
    return $self->_elements->{$name};
}

sub update {
    my ($self, $name, $job) = @_;
    my $old = delete $self->_elements->{$job->name} or croak "$name is not registered";
    $self->_elements->{$job->name} = $job;
    return $old;
}

sub register {
    my ($self, $job) = @_;
    croak $job->name . " is already registered" if $self->_elements->{$job->name};
    $self->_elements->{$job->name} = $job;
}

sub deregister {
    my ($self, $name) = @_;
    my $old = delete $self->_elements->{$name} or croak "$name is not registered";
    return $old;
}


1;
