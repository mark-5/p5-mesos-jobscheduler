package Mesos::JobScheduler::Role::Interface::Registrar;
use Moo::Role;

requires qw(
    add_job
    get_job
    remove_job
    update_job
);

1;
