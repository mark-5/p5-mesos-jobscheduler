package Mesos::JobScheduler::Manager::Traits::OneOff;

use Scalar::Util qw(weaken);
use Moose::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Manager::Traits::HandlesTimers';

sub _add_one_off_job {
    my ($self, $job) = @_;
    $self->add_timer($job,
        cb => sub {
            my ($self, $job) = @_;
            $self->queue_execution($job);
        },
        scheduled => $job->scheduled,
    );
}

sub _remove_one_off_job {
    my ($self, $job) = @_;
    $self->remove_timer($job->id);
}

after attach_listeners => sub {
    weaken(my $self = shift);

    $self->on('add:OneOff', sub {
        my ($job) = @_;
        $self->_add_one_off_job($job);
    });

    $self->on('update:OneOff', sub {
        my ($new) = @_;
        $self->_remove_one_off_job($new);
        $self->_add_one_off_job($new) unless $new->suspended;
    });

    $self->on('remove:OneOff', sub {
        my ($job) = @_;
        $self->_remove_one_off_job($job);
    });

    $self->on("$_:OneOff", sub {
        my ($execution) = @_;
        $self->remove_job($execution->job_id);
    }) for qw(finish fail);
};

1;
