package Mesos::JobScheduler::Role::Manager::Cron;
use Mesos::JobScheduler::Utils qw(now);
use Scalar::Util qw(weaken);
use Moo::Role;
use namespace::autoclean;

has _cron_jobs => (
    is      => 'ro',
    default => sub { {} },
);

sub _add_cron_job {
    my ($self, $job) = @_;
    my $scheduled = $job->scheduled;
    $self->_cron_jobs->{$job->id} = {
        job       => $job,
        scheduled => $scheduled,
    };

    my $timer = $self->_cron_timer->{next};
    $self->_reset_cron_timer if !$timer or $scheduled < $timer;
}

sub _remove_cron_job {
    my ($self, $id) = @_;
    my $old = delete $self->_cron_jobs->{$id};
    $self->_reset_cron_timer if $old->{scheduled} == $self->_cron_timer->{next};
    return $old;
}

has _cron_timer => (
    is      => 'ro',
    clearer => '_clear_cron_timer',
    writer  => '_set_cron_timer',
    default => sub { {} },
);

sub _find_next_cron_time {
    my ($self) = @_;
    my @crons =
        sort { $a->{scheduled} <=> $b->{scheduled} }
        values %{$self->_cron_jobs};
    return $crons[0]->{scheduled};
}

sub _reset_cron_timer {
    weaken(my $self = $_[0]);

    my $next = $self->_find_next_cron_time;
    if (!$next) {
        $self->_clear_cron_timer;
        return;
    }
    my $delta = $next->epoch - now()->epoch;

    if ($delta > 0) {
        my $timer = $self->new_timer(after => $delta);
        $timer->on_done(sub {
            $self->_queue_ready_cron_jobs;
            $self->_reset_cron_timer;
        });
        $self->_set_cron_timer({
            next  => $next,
            timer => $timer,
        });
    } else {
        $self->_queue_ready_cron_jobs;
        $self->_reset_cron_timer;
    }
}

sub _queue_ready_cron_jobs {
    my ($self) = @_;
    my $now    = now();
    my @ready  =
        map  { $_->{job}                           }
        sort { $a->{scheduled} <=> $b->{scheduled} }
        grep { $_->{scheduled} <=  $now            }
        values %{$self->_cron_jobs};

    for my $job (@ready) {
        $self->queue_execution($job);
        $self->update_job($job->id, scheduled => $job->next);
    }
}

sub _is_cron_job {
    my ($self, $id_or_job) = @_;
    my $job = ref $id_or_job ? $id_or_job : $self->get_job($id_or_job);
    return $job->isa('Mesos::JobScheduler::Job::Cron');
}


after add_job => sub {
    my ($self, $job) = @_;
    return unless $self->_is_cron_job($job);

    $self->_add_cron_job($job);
};

around update_job => sub {
    my ($orig, $self, $id, %args) = @_;
    my $new = $self->$orig($id, %args);

    $self->_add_cron_job($new) if $self->_is_cron_job($new);
    return $new;
};

before remove_job => sub {
    my ($self, $id) = @_;
    return unless $self->_is_cron_job($id);

    $self->_remove_cron_job($id);
};

1;
