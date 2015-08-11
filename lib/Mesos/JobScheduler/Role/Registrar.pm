package Mesos::JobScheduler::Role::Registrar;

use Mesos::JobScheduler::Types qw(to_Job);
use Mesos::JobScheduler::Utils qw(now);
use Moo::Role;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::HasBUILD
    Mesos::JobScheduler::Role::HasStorage
    Mesos::JobScheduler::Role::Interface::Logger
    Mesos::JobScheduler::Role::Interface::Registrar
);

# ABSTRACT: a role for registering jobs

=head1 METHODS

=head2 add_job

=head2 get_job

=head2 jobs

=head2 remove_job

=head2 update_job

=cut

sub _registry {
    my ($self, $cmd, $node, @args) = @_;
    $node = "/mesos-jobscheduler/registrar/$node";
    return $self->storage->$cmd($node, @args);
}


sub add_job {
    my ($self, $job, %args) = @_;
    $self->_registry(store => $job->id, $job) unless $args{from_storage};
    $self->log_info("added job " . $job->id);
}

sub get_job {
    my ($self, $id) = @_;
    my $info = $self->_registry(retrieve => $id) or return;
    return to_Job $info;
}

sub remove_job {
    my ($self, $id) = @_;
    my $old = to_Job $self->_registry(delete => $id);
    $self->log_info("removed job $id");
    return $old;
}

sub update_job {
    my ($self, $id, %args) = @_;
    my $old = $self->get_job($id);
    my $new = $old->update(%args);

    $self->_registry(update => $id, $new);
    $self->log_info("updated job $id");
    return $new;
}

sub jobs {
    my ($self) = @_;
    my @jobs =
        map  { $self->get_job($_) }
        $self->storage->list('/mesos-jobscheduler/registrar');
    return @jobs;
}

after BUILD => sub {
    my ($self) = @_;
    $self->add_job($_, from_storage => 1) for $self->jobs;
};

1;
