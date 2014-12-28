package Mesos::Framework::JobScheduler::Role::Schedule::HandlesTimers;
use AnyEvent;
use DateTime;
use Moo::Role;
with qw(
    Mesos::Framework::JobScheduler::Role::HandlesAnyEventTime
    Mesos::Framework::JobScheduler::Role::Schedule
);


has timers => (
    is => "ro",
    default => sub { {} },
);


sub get_timer {
    my ($self, $name) = @_;
    return $self->timers->{$name};
}

sub get_timers {
    my ($self) = @_;
    return sort {$a->{scheduled_time} <=> $b->{scheduled_time}} values %{$self->timers};
}

sub register_timer {
    my ($self, $job) = @_;
    my ($name, $scheduled_time) = map {$job->$_} qw(name scheduled_time);

    my $duration = $scheduled_time - $self->now;
    my $cb = sub { $job->status("ready"); $self->deregister_timer($name) };
    my $w; $w = AnyEvent->timer(
        after => $duration->in_units("seconds"),
        cb    => $cb,
    );

    return $self->timers->{$name} = {
        scheduled_time => $scheduled_time,
        watcher        => $w,
        cb             => $cb,
    };
}

sub deregister_timer {
    my ($self, $name) = @_;
    return delete $self->timers->{$name};
}

after register => sub {
    my ($self, $job) = @_;
    $self->register_timer($job) if $job->does("Mesos::Framework::JobScheduler::Role::Job::HasTimer");
};

after deregister => sub {
    my ($self, $name) = @_;
    $self->deregister_timer($name);
};


1;
