package Mesos::JobScheduler::XUnit::Crontab;
use Try::Tiny;
use AnyEvent;
use DateTime;
use Mesos::JobScheduler::XUnit::Utils qw(ae_sleep);
use Test::Class::Moose;

with "Mesos::JobScheduler::XUnit::Role::HandlesJobScheduling" => {
    schedules => {
        schedule => ["UsesHashStorage", "HandlesTimers"]
    },
    jobs => {
        job => ["HasCrontab"],
    },
};


sub test_basic_timer {
    my ($self) = @_;
    my $schedule = $self->schedule->new;
    my $job = $self->job->new(
        crontab => "* * * * *",
    );
    $schedule->register($job);
    ok $schedule->get_timer($job->name), 'cron job registered timer';
    $schedule->deregister($job->name);
    ok !$schedule->get_timer($job->name), 'no timer after deregistering cron job';
}

sub test_executions {
    my ($self) = @_;
    my $every_minute = $self->job->new(
        crontab => "* * * * *",
    );
    my $six_min = $every_minute->now->add(minutes => 6);
    is scalar($every_minute->executions(until => $six_min)), 6, "minutely crontab has six executions in next six minutes";

    my $every_other_minute = $self->job->new(
        crontab => "*/2 * * * *",
    );
    is scalar($every_other_minute->executions(until => $six_min)), 3, "crontab for every other minute has three executions in next six minutes";
}

1;
