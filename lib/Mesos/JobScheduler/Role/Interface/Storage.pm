package Mesos::JobScheduler::Role::Interface::Storage;

use Moo::Role;
use namespace::autoclean;

requires qw(
    delete
    exists
    list
    retrieve
    store
    update
);

1;
