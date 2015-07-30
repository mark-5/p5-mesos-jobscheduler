package Mesos::JobScheduler::Role::Interface::Timer;
use Moo::Role;
use namespace::autoclean;

requires qw(
    add_timer
    remove_timer
);

1;
