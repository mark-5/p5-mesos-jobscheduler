package Mesos::JobScheduler::Manager;
use Moo;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Interface::Executioner
    Mesos::JobScheduler::Role::HasId
);

has scheduler => (
    is       => 'ro',
    writer   => 'set_scheduler',
    weak_ref => 1,
);

sub filter { }

sub add_job    { }
sub remove_job { }

sub queue_job  { }
sub start_job  { }
sub finish_job { }
sub fail_job   { }

1;
