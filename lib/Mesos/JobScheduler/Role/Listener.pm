package Mesos::JobScheduler::Role::Listener;
use Moo::Role;
use namespace::autoclean;

sub start_listener {};

sub stop_listener {};

sub BUILD {}
after BUILD => sub { shift->start_listener };

sub DEMOLISH {}
after DEMOLISH => sub { shift->stop_listener };

1;
