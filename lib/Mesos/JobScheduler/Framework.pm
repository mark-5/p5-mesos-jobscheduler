package Mesos::JobScheduler::Framework;

use List::MoreUtils qw(any);
use Mesos::JobScheduler::Utils qw(now);
use Mesos::Messages;
use Moose;
use namespace::autoclean;
extends 'Mesos::Scheduler';

has manager => (
    is       => 'ro',
    required => 1,
    handles  => [qw(
        fail_execution
        finish_execution
        queue_execution
        queued
        start_execution
    )],
);

has _tasks => (
    is      => 'ro',
    default => sub { {} },
);

sub resourceOffers {
    my ($self, $driver, $offers) = @_;
    my %tasks;

    for my $execution ($self->queued) {
        my $job   = $execution->job;
        my $offer = $self->_claim_offer_for_job($job, $offers) or next;
        my $task  = $self->_job_to_task($job, $offer);

        push @{$tasks{$offer->{id}{value}}||=[]}, $task;
        $self->_tasks->{$task->{task_id}{value}} = {
            execution_id => $execution->id,
            launched     => now(),
            task         => $task,
        };
        $self->start_execution($execution->id);
    }
    for my $offer (@$offers) {
        my $offer_id = $offer->{id};
        if (my $tasks = $tasks{$offer_id->{value}}) {
            $driver->launchTasks([$offer_id], $tasks);
        } else {
            $driver->declineOffer($offer_id);
        }
    }
}

sub statusUpdate {
    my ($self, $driver, $status) = @_;
    my $task_id      = $status->{task_id}{value};
    my $execution_id = $self->_tasks->{$task_id}{execution_id};

    my $finished = $status->{state} == Mesos::TaskState::TASK_FINISHED;
    my $failed   = any {$status->{state} == $_}
        Mesos::TaskState::TASK_FAILED,
        Mesos::TaskState::TASK_KILLED,
        Mesos::TaskState::TASK_LOST;

    if ($finished) {
        $self->finish_execution($execution_id);
        delete $self->_tasks->{$task_id};
    } elsif ($failed) {
        $self->fail_execution($execution_id);
        delete $self->_tasks->{$task_id};
    }
}

sub _job_to_mesos_resources {
    my ($self, $job) = @_;
    my $resources    = $job->resources;
    return map {
        my $type = $_;
        Mesos::Resource->new({
            name   => $type,
            type   => Mesos::Value::Type::SCALAR,
            scalar => {value => $resources->{$type}},
        });
    } sort keys %$resources;
}

sub _job_to_task {
    my ($self, $job, $offer) = @_;
    return Mesos::TaskInfo->new({
        command   => {value => $job->command},
        name      => $job->name,
        resources => [$self->_job_to_mesos_resources($job)],
        slave_id  => $offer->{slave_id},
        task_id   => {value => $job->name},
    });
}

sub _claim_offer_for_job {
    my ($self, $job, $offers) = @_;
    my $required = $job->resources;
    OFFER: for my $offer (@$offers) {
        my %available = map {$_->{name} => $_} @{$offer->{resources}};
        for my $name (keys %$required) {
            my $resource = $available{$name};
            next OFFER if not $resource;
            next OFFER if $resource->{scalar}{value} < $required->{$name};
        }
        for my $name (keys %$required) {
            my $resource = $available{$name};
            $resource->{scalar}{value} -= $required->{$name};
        }
        return $offer;
    }
}

__PACKAGE__->meta->make_immutable;
1;
