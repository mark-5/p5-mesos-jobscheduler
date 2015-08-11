package Mesos::JobScheduler::Role::Executioner;

use Mesos::JobScheduler::Types qw(to_Execution);
use Mesos::JobScheduler::Utils qw(now);
use Moo::Role;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::HasStorage
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

sub _executions {
    my ($self, $cmd, $node, @args) = @_;
    $node = "/mesos-jobscheduler/executioner/$node";
    return $self->storage->$cmd($node, @args);
}

sub _update_execution {
    my ($self, $id, $status) = @_;
    my $old = $self->get_execution($id);
    my $new = $old->update(status => $status);

    $self->_executions(update => "execution/$id", $new);
    $self->_executions(delete => $old->status."/$id");
    $self->_executions(store  => "$status/$id");
    return $new;
}

sub _remove_execution {
    my ($self, $id) = @_;
    my $old = to_Execution $self->_executions(delete => "execution/$id");
    if (my $status = $old->{status}) {
        $self->_executions(delete => "$status/$id");
    }
    return $old;
}

sub get_execution {
    my ($self, $id) = @_;
    my $info = $self->_executions(retrieve => "execution/$id") or return;
    return to_Execution $info;
}

sub queue_execution {
    my ($self, $job) = @_;
    $self->log_info('queued execution for job ' . $job->id);

    my $execution = to_Execution {job => $job, status => 'queued'};
    my $id = $execution->id;
    $self->_executions(store => "execution/$id", $execution);
    $self->_executions(store => "queued/$id");

    return $id;
}

sub start_execution {
    my ($self, $id) = @_;
    my $execution = $self->_update_execution($id, 'running');
    $self->log_info('started execution for job ' . $execution->job->id);
    return $execution;
}

sub finish_execution {
    my ($self, $id) = @_;
    my $execution = $self->_remove_execution($id);
    $self->log_info('finished execution for job ' . $execution->job->id);
    return $execution;
}

sub fail_execution {
    my ($self, $id) = @_;
    my $execution = $self->_remove_execution($id);
    $self->log_info('failed execution for job ' . $execution->job->id);
    return $execution;
}

sub executions {
    my ($self) = @_;
    return $self->_executions(list => "execution");
}

sub queued {
    my ($self) = @_;
    my @queue =
        sort { $a->updated <=> $b->updated }
        map  { $self->get_execution($_)    }
        $self->_executions(list => "queued");
    return @queue;
}

1;
