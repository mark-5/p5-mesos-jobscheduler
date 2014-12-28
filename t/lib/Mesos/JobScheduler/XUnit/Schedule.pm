package Mesos::JobScheduler::XUnit::Schedule;
use Test::Class::Moose;

with "Mesos::JobScheduler::XUnit::Role::HandlesJobScheduling" => {
    schedules => {
        schedule => ["UsesHashStorage", "HandlesTimers"]
    },
    jobs => {
        job     => ["HasTimer"],
        cronjob => ["HasCrontab"],
    },
};

sub test_executions {
    my ($self) = @_;
    my $schedule = $self->schedule->new;
    my $in_five = $schedule->now->add(minutes => 5);

    my $too_early = $self->job->new(scheduled_time => $schedule->now->subtract(minutes => 1));
    my $too_late  = $self->job->new(scheduled_time => $schedule->now->add(minutes => 6));
    my $in_time   = $self->job->new(scheduled_time => $schedule->now->add(minutes => 4));
    my $every_min = $self->cronjob->new(crontab => "* * * * *");
    my @jobs = ($too_early, $too_late, $in_time, $every_min);
    $schedule->register($_) for @jobs;

    my @executions = $schedule->executions(until => $in_five);
    is scalar(grep {$_->{name} eq $too_early->name} @executions), 0, 'job scheduled too early has no executions';
    is scalar(grep {$_->{name} eq $too_late->name} @executions), 0, 'job scheduled too late has no executions';
    is scalar(grep {$_->{name} eq $in_time->name} @executions), 1, 'job scheduled in time has execution';
    is scalar(grep {$_->{name} eq $every_min->name} @executions), 5, 'minutely cronjob has five executions in five minute window';

    $schedule->deregister($_->name) for @jobs;
}

1;
