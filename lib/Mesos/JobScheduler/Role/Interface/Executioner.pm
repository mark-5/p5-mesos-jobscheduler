package Mesos::JobScheduler::Role::Interface::Executioner;
use Moo::Role;
use namespace::autoclean;

requires qw(
    queued

    queue_execution
    start_execution
    finish_execution
);

1;
