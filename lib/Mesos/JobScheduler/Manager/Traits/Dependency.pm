package Mesos::JobScheduler::Manager::Traits::Dependency;

use Mesos::JobScheduler::Utils qw(now);
use Scalar::Util qw(weaken);
use Moose::Role;
use namespace::autoclean;

has _job_dependencies => (
    is      => 'ro',
    default => sub { {} },
);

has _parent_jobs => (
    is      => 'ro',
    default => sub { {} },
);

sub _add_job_dependency {
    my ($self, $job) = @_;
    my $dependency = $self->_job_dependencies->{$job->id} = {
        added  => now(),
        job    => $job,
        parent => $job->parent,
    };
    $self->_parent_jobs->{$job->parent}{$job->id} = $dependency;
}

sub _remove_job_dependency {
    my ($self, $job) = @_;
    my $dependency = delete $self->_job_dependencies->{$job->id} or return;
    delete $self->_parent_jobs->{$dependency->{parent}};
}

after attach_listeners => sub {
    weaken(my $self = shift);

    $self->on('add:Dependency', sub {
        my ($job) = @_;
        $self->_add_job_dependency($job);
    });

    $self->on('update:Dependency', sub {
        my ($new) = @_;
        $self->_remove_job_dependency($new);
        $self->_add_job_dependency($new) unless $new->suspended;
    });

    $self->on('remove:Dependency', sub {
        my ($job) = @_;
        $self->_remove_job_dependency($job);
    });

    $self->on('finish', sub {
        my ($execution) = @_;
        my $parent      = $execution->job;
        $self->queue_execution($_->{job})
            for values %{$self->_parent_jobs->{$parent->id}||{}};
    });
};

1;
