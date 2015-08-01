package Mesos::JobScheduler::Role::Core;

use Moo::Role;
use namespace::autoclean;

with qw(
    Mesos::JobScheduler::Role::Executioner
    Mesos::JobScheduler::Role::HasEventLoop
    Mesos::JobScheduler::Role::HasTimers
    Mesos::JobScheduler::Role::HasLogger
    Mesos::JobScheduler::Role::Registrar
    Mesos::JobScheduler::Role::TaskScheduler
);

1;
