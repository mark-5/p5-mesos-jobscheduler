package Mesos::JobScheduler;
use Moo;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::HandlesRegistration
    Mesos::JobScheduler::Role::HandlesExecutions
    Mesos::JobScheduler::Role::HandlesManagerDispatching
);

# ABSTRACT: a base class for Mesos job scheduling frameworks

1;
