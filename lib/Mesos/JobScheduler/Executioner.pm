package Mesos::JobScheduler::Executioner;

use Mesos::JobScheduler::Types qw(to_Execution);
use Mesos::JobScheduler::Utils qw(now);
use Moose;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Events';

has logger => (
    is       => 'ro',
    required => 1,
);

has storage => (
    is       => 'ro',
    required => 1,
);

sub get {
    my ($self, $id) = @_;
    return to_Execution $self->storage->get("executions/$id");
}

sub queue {
    my ($self, $job) = @_;

    my $execution = to_Execution {
        job    => $job,
        status => 'queued',
    };
    $self->storage->add('executions/'.$execution->id, $execution);
    $self->storage->add('queued/'.$execution->id, $execution->id);

    $self->logger->info('queued execution for job '.$job->id);
    $self->trigger('queue:'.$job->type, $execution);
    return $execution;
}

sub start {
    my ($self, $id) = @_;

    my $old = $self->get($id);
    my $new = $old->update(status => 'started');

    $self->storage->update("executions/$id", $new);
    $self->storage->remove($old->status."/$id");
    $self->storage->add("started/$id", $new);

    $self->logger->info('started execution for job '.$new->job_id);
    $self->trigger('start:'.$new->type, $new);
    return $new;
}

sub fail {
    my ($self, $id) = @_;

    my $old = to_Execution $self->storage->remove("executions/$id");
    $self->storage->remove($old->status."/$id");

    $self->logger->info('failed execution for job '.$old->job_id);
    $self->trigger('fail:'.$old->type, $old);
}

sub finish {
    my ($self, $id) = @_;

    my $old = to_Execution $self->storage->remove("executions/$id");
    $self->storage->remove($old->status."/$id");

    $self->logger->info('finished execution for job '.$old->job_id);
    $self->trigger('finish:'.$old->type, $old);
}

sub queued {
    my ($self) = @_;
    my @queue =
        sort { $a->created <=> $b->created }
        map  { $self->get($_)              }
        $self->storage->get_children('queued');
    return @queue;
}

sub all {
    my ($self) = @_;
    my @executions = 
        sort { $a->created <=> $b->created }
        map  { $self->get($_)              }
        $self->storage->get_children('executions');
    return @executions;
}

__PACKAGE__->meta->make_immutable;
1;
