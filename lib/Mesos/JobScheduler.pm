package Mesos::JobScheduler;
use Moo;
use namespace::autoclean;
extends 'Mesos::Scheduler';
with qw(
    Mesos::JobScheduler::Role::Executioner
    Mesos::JobScheduler::Role::HasEventLoop
    Mesos::JobScheduler::Role::HasTimers
    Mesos::JobScheduler::Role::Manager::Cron
    Mesos::JobScheduler::Role::Registrar
    Mesos::JobScheduler::Role::TaskScheduler
);

# ABSTRACT: a base class for Mesos job scheduling frameworks

1;
