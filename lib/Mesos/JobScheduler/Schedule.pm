package Mesos::JobScheduler::Schedule;
use Moo;

with qw(
    Mesos::JobScheduler::Role::Schedule::UsesHashStorage
    Mesos::JobScheduler::Role::Schedule::HandlesTimers
    Mesos::JobScheduler::Role::Schedule::HandlesDependencies
);


1;
