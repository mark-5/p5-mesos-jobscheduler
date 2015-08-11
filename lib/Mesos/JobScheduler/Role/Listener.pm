package Mesos::JobScheduler::Role::Listener;

use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::HasBUILD';

sub start_listener {};

sub stop_listener {};

after BUILD => sub { shift->start_listener };

sub DEMOLISH {}
after DEMOLISH => sub { shift->stop_listener };

1;
