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

sub test_startup { shift->test_skip("TODO: schedule executions tests") }

sub test_executions {
    my ($self) = @_;
}

1;
