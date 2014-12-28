package Mesos::Framework::XUnit::Timer;
use Try::Tiny;
use AnyEvent;
use DateTime;
use Mesos::Framework::XUnit::Utils qw(ae_sleep);
use Test::Class::Moose;

with "Mesos::Framework::XUnit::Role::HasSchedules" => {
    schedules => {
        schedule => ["UsesHashStorage", "HandlesTimers"]
    },
};
with "Mesos::Framework::XUnit::Role::HasJobs" => {
    jobs => {
        job => ["HasTimer"],
    },
};


sub test_basic_timer {
    my ($self) = @_;
    my $schedule = $self->schedule->new;;
    my $job = $self->job->new(
        scheduled_time => $schedule->now->add(seconds => 1),
    );
    $schedule->register($job);
    is scalar(grep {$_->status eq 'ready'} $schedule->all), 0, "no jobs are ready after registering";
    ae_sleep(1);
    is scalar(grep {$_->status eq 'ready'} $schedule->all), 1, "no jobs are ready after registering";
    $schedule->deregister($job->name);
}

1;
