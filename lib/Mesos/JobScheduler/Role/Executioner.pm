package Mesos::JobScheduler::Role::Executioner;
use Hash::Ordered;
use Mesos::JobScheduler::Utils qw(now);
use Types::UUID qw(Uuid);
use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Interface::Executioner';

# ABSTRACT: a role for managing job executions

=head1 METHODS

=head2 get_execution

=head2 fail_execution

=head2 finish_execution

=head2 queue_execution

=head2 queued

=head2 start_execution

=cut

has _executions => (
    is      => 'ro',
    default => sub { Hash::Ordered->new },
);

has _execution_statuses => (
    is      => 'ro',
    default => sub { {} },
);

sub _add_execution {
    my ($self, $job, $status) = @_;
    my $id = Uuid->generate;
    $self->_executions->push($id, {
        added  => now(),
        id     => $id,
        job    => $job,
    });
    $self->_update_execution_status($id, $status);
    return $id;
}

sub _update_execution_status {
    my ($self, $id, $status) = @_;
    my $execution = $self->_executions->get($id);
    if (my $old = delete $execution->{status}) {
        $self->_execution_statuses->{$old}->delete($id);
    }
    $execution->{status}  = $status;
    $execution->{updated} = now();

    my $ids = $self->_execution_statuses->{$status} //= Hash::Ordered->new;
    $ids->push($id, $execution);
}

sub _remove_execution {
    my ($self, $id) = @_;
    my $execution  = $self->_executions->delete($id);
    if (my $status = $execution->{status}) {
        return $self->_execution_statuses->{$status}->delete($id);
    }
}

sub get_execution {
    my ($self, $id) = @_;
    return $self->_executions->get($id);
}

sub queue_execution {
    my ($self, $job) = @_;
    return $self->_add_execution($job, 'queued');
}

sub start_execution {
    my ($self, $id) = @_;
    $self->_update_execution_status($id, 'running');
}

sub finish_execution {
    my ($self, $id) = @_;
    $self->_remove_execution($id);
}

sub fail_execution {
    my ($self, $id) = @_;
    $self->_remove_execution($id);
}

sub queued {
    my ($self) = @_;
    my $queued = $self->_execution_statuses->{queued} //= Hash::Ordered->new;
    return map { {%$_} } $queued->values;
}

1;
