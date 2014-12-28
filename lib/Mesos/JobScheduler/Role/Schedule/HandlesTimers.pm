package Mesos::JobScheduler::Role::Schedule::HandlesTimers;
use AnyEvent;
use DateTime;
use Moo::Role;
with qw(
    Mesos::JobScheduler::Role::HandlesAnyEventTime
    Mesos::JobScheduler::Role::Schedule
);

=head1 NAME

Mesos::JobScheduler::Role::Schedule::HandlesTimers

=head1 METHODS

=head2 get_timer($name)

=head2 executions(from => $from_dt, until => $until_dt)

=head2 register_timer($job)

=head2 deregister_timer($name)

=cut


has timers => (
    is      => "ro",
    default => sub { {} },
);


sub get_timer {
    my ($self, $name) = @_;
    return $self->timers->{$name};
}

sub executions {
    my ($self, %args) = @_;
    my @jobs = map {$self->get($_)} keys %{$self->timers};
    my @executions;
    for my $job (@jobs) {
        push @executions, map {name => $job->name, scheduled_time => $job->scheduled_time, job => $job}, $job->executions(%args);
    }
    return sort {($a->{scheduled_time} <=> $b->{scheduled_time}) || ($a->{name} cmp $b->{name})} @executions;
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
    $self->register_timer($job) if $job->does("Mesos::JobScheduler::Role::Job::HasTimer");
};

after deregister => sub {
    my ($self, $name) = @_;
    $self->deregister_timer($name);
};


1;
