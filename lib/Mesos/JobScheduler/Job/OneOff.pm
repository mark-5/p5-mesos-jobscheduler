package Mesos::JobScheduler::Job::OneOff;
use Moo;
use Mesos::JobScheduler::Utils qw(now);
extends 'Mesos::JobScheduler::Job';
use namespace::autoclean;

has scheduled => (
    is      => 'ro',
    default => sub { now() },
);

1;
