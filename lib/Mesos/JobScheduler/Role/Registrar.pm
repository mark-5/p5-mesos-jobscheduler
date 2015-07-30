package Mesos::JobScheduler::Role::Registrar;
use Mesos::JobScheduler::Utils qw(now);
use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Interface::Registrar';

has _registry => (
    is      => 'ro',
    default => sub { {} },
);


sub add_job {
    my ($self, $job) = @_;
    $self->_registry->{$job->id} = {
        added => now(),
        job   => $job,
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
    my $old = $self->_registry->{$id};
    $old->{updated} = now();
    return $old->{job} = $old->{job}->update(%args);
}

1;