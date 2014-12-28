package Mesos::Framework::JobScheduler::Schedule;
use Moo;

with qw(
    Mesos::Framework::JobScheduler::Role::Schedule::UsesHashStorage
    Mesos::Framework::JobScheduler::Role::Schedule::HandlesTimers
    Mesos::Framework::JobScheduler::Role::Schedule::HandlesDependencies
);


1;
