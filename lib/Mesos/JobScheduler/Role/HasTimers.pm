package Mesos::JobScheduler::Role::HasTimers;
use Mesos::JobScheduler::Utils qw(now);
use Scalar::Util qw(weaken);
use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Interface::EventLoop';

has _next_timer => (
    is      => 'ro',
    writer  => '_set_next_timer',
    default => sub { {} },
);

has _timers => (
    is      => 'ro',
    default => sub { {} },
);

sub _reset_next_timer {
    weaken(my $self = $_[0]);

    my $next = $self->_find_next_time;
    if (!$next) {
        $self->_set_next_timer({});
        return;
    }
    my $delta = $next->epoch - now()->epoch;

    if ($delta > 0) {
        my $timer = $self->new_timer(after => $delta);
        $timer->on_done(sub {
            $self->_call_ready_timers;
            $self->_reset_next_timer;
        });
        $self->_set_next_timer({
            next  => $next,
            timer => $timer,
        });
    } else {
        $self->_call_ready_timers;
        $self->_reset_next_timer;
    }
}

sub _find_next_time {
    my ($self) = @_;
    my @timers =
        sort { $a->{scheduled} <=> $b->{scheduled} }
        values %{$self->_timers};
    return $timers[0]->{scheduled};
}

sub _call_ready_timers {
    my ($self) = @_;
    my $now    = now();
    my @ready  =
        sort { $a->{scheduled} <=> $b->{scheduled} }
        grep { $_->{scheduled} <=  $now            }
        values %{$self->_timers};

    for my $timer (@ready) {
        my ($cb, $job) = @{$timer}{qw(cb job)};
        delete $self->_timers->{$job->id};
        $self->$cb($job);
    }
}

sub add_timer {
    my ($self, $job, %args) = @_;
    my ($cb, $scheduled) = @args{qw(cb scheduled)};
    $self->_timers->{$job->id} = {
        cb        => $cb,
        job       => $job,
        scheduled => $scheduled,
    };
    $self->_reset_next_timer;

    my $timer = $self->_next_timer->{next};
    $self->_reset_next_timer if !$timer or $scheduled < $timer;
}

sub remove_timer {
    my ($self, $id) = @_;
    my $old = delete $self->_timers->{$id} or return;
    $self->_reset_next_timer if $old->{scheduled} == $self->_next_timer->{next};
    return $old;
}

1;
