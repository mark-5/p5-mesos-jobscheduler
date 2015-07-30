package Mesos::JobScheduler::Job::Dependency;
use Moo;
use namespace::autoclean;
extends 'Mesos::JobScheduler::Job';

has parent => (
    is       => 'ro',
    required => 1,
);

1;
