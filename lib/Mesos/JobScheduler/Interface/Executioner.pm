package Mesos::JobScheduler::Interface::Executioner;
use Moo::Role;

requires qw(
    add_job
    remove_job

    queue_job
    start_job
    finish_job
    fail_job
);

1;
