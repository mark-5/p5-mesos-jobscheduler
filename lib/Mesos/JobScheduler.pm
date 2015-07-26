package Mesos::JobScheduler;
use Moo;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::HasEventLoop
    Mesos::JobScheduler::Role::Registrar
    Mesos::JobScheduler::Role::Registrar::WithExecutions
    Mesos::JobScheduler::Role::Manager::Cron
);

# ABSTRACT: a base class for Mesos job scheduling frameworks

1;
