package Mesos::JobScheduler::Manager::Traits::Cron;

use Mesos::JobScheduler::Utils qw(now);
use Scalar::Util qw(weaken);
use Moose::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Manager::Traits::HandlesTimers';

sub _add_cron_job {
    my ($self, $job) = @_;
    $self->add_timer($job,
        cb => sub {
            my ($self, $job) = @_;
            $self->queue_execution($job);
            $self->update_job($job->id, scheduled => $job->next);
        },
        scheduled => $job->scheduled,
    );
}

sub _remove_cron_job {
    my ($self, $job) = @_;
    $self->remove_timer($job->id);
}

after attach_listeners => sub {
    weaken(my $self = shift);

    $self->on('add:Cron', sub {
        my ($job) = @_;
        $self->_add_cron_job($job);
    });

    $self->on('update:Cron', sub {
        my ($new) = @_;
        $self->_remove_cron_job($new);
        $self->_add_cron_job($new) unless $new->suspended;
    });

    $self->on('remove:Cron', sub {
        my ($job) = @_;
        $self->_remove_cron_job($job);
    });
};

1;
