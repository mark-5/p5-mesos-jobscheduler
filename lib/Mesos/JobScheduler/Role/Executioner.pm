package Mesos::JobScheduler::Role::Executioner;

use Hash::Ordered;
use Mesos::JobScheduler::Utils qw(now);
use Types::UUID qw(Uuid);
use Moo::Role;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::Interface::Executioner
    Mesos::JobScheduler::Role::Interface::Logger
);

# ABSTRACT: a role for managing job executions

=head1 METHODS

=head2 executions

=head2 fail_execution

=head2 finish_execution

=head2 get_execution

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
    return $execution;
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
    $self->log_info('queued execution for job ' . $job->id);
    return $self->_add_execution($job, 'queued');
}

sub start_execution {
    my ($self, $id) = @_;
    my $execution = $self->_update_execution_status($id, 'running');
    $self->log_info('started execution for job ' . $execution->{job}->id);
    return $execution;
}

sub finish_execution {
    my ($self, $id) = @_;
    my $execution = $self->_remove_execution($id);
    $self->log_info('started execution for job ' . $execution->{job}->id);
    return $execution;
}

sub fail_execution {
    my ($self, $id) = @_;
    my $execution = $self->_remove_execution($id);
    $self->log_info('started execution for job ' . $execution->{job}->id);
    return $execution;
}

sub executions {
    my ($self) = @_;
    return $self->_executions->values;
}

sub queued {
    my ($self) = @_;
    my $queued = $self->_execution_statuses->{queued} //= Hash::Ordered->new;
    return map { {%$_} } $queued->values;
}

1;
