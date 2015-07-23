package Mesos::JobScheduler::Role::HandlesRegistration;
use Time::HiRes qw();
use Moo::Role;
use namespace::autoclean;

has _registry => (
    is      => 'ro',
    default => sub { {} },
);


sub add_job {
    my ($self, $job) = @_;
    my $now = Time::HiRes::time;
    $self->_registry->{$job->id} = {
        job  => $job,
        time => $now,
    };
}

sub get_job {
    my ($self, $id) = @_;
    return $self->_registry->{$id}{job};
}

sub remove_job {
    my ($self, $id) = @_;
    my $old = delete $self->_registry->{$id};
    return $old->{job};
}

sub update_job {
    my ($self, $id, %args) = @_;
    my $old = $self->_registry->{$id}{job};
    return $self->_registry->{$id}{job} = $old->update(%args);
}

1;
