package Mesos::JobScheduler::Role::Registrar;
use Mesos::JobScheduler::Utils qw(now);
use Moo::Role;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::Interface::Logger
    Mesos::JobScheduler::Role::Interface::Registrar
);

# ABSTRACT: a role for registering jobs

=head1 METHODS

=head2 add_job

=head2 get_job

=head2 remove_job

=head2 update_job

=cut

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
    $self->log_info("added job " . $job->id);
}

sub get_job {
    my ($self, $id) = @_;
    return $self->_registry->{$id}{job};
}

sub remove_job {
    my ($self, $id) = @_;
    my $old = delete $self->_registry->{$id};
    $self->log_info("removed job " . $old->{job}->id);
    return $old->{job};
}

sub update_job {
    my ($self, $id, %args) = @_;
    my $old = $self->_registry->{$id};
    $old->{updated} = now();
    my $job = $old->{job} = $old->{job}->update(%args);

    $self->log_info("updated job " . $job->id);
    return $job;
}

1;
