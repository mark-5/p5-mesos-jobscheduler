package Mesos::JobScheduler::Executioner;

use Mesos::JobScheduler::Types qw(to_Execution);
use Mesos::JobScheduler::Utils qw(now);
use Moose;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Events';

has logger => (
    is => 'ro',
);

has storage => (
    is => 'ro',
);

sub retrieve {
    my ($self, $id) = @_;
    return to_Execution $self->storage->retrieve("executions/$id");
}

sub queue {
    my ($self, $job) = @_;

    my $execution = to_Execution {
        job    => $job,
        status => 'queued',
    };
    $self->storage->create('executions/'.$execution->id, $execution);
    $self->storage->create('queued/'.$execution->id);

    $self->trigger('queue:'.$job->type, $execution);
    $self->logger->info('queued execution for job '.$job->id);
    return $execution;
}

sub start {
    my ($self, $id) = @_;

    my $old = $self->retrieve($id);
    my $new = $old->update(status => 'started');

    $self->storage->update("executions/$id", $new);
    $self->storage->delete($old->status."/$id");
    $self->storage->create("started/$id", $new);

    $self->trigger('start:'.$new->type);
    $self->logger->info('started execution for job '.$new->job_id);
    return $new;
}

sub fail {
    my ($self, $id) = @_;

    my $old = to_Execution $self->storage->delete("executions/$id");
    $self->storage->delete($old->status."/$id");

    $self->trigger('fail:'.$old->type, $old);
    $self->logger->info('failed execution for job '.$old->job_id);
}

sub finish {
    my ($self, $id) = @_;

    my $old = to_Execution $self->storage->delete("executions/$id");
    $self->storage->delete($old->status."/$id");

    $self->trigger('finish:'.$old->type);
    $self->logger->info('finished execution for job '.$old->job_id);
}

sub queued {
    my ($self) = @_;
    my @queue =
        sort { $a->created <=> $b->created }
        map  { $self->retrieve($_)         }
        $self->storage->retrieve_children('queued');
    return @queue;
}

sub all {
    my ($self) = @_;
    my @executions = 
        sort { $a->created <=> $b->created }
        map  { $self->retrieve($_)         }
        $self->storage->retrieve_children('executions');
    return @executions;
}

__PACKAGE__->meta->make_immutable;
1;
