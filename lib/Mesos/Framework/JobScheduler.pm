package Mesos::Framework::JobScheduler;
use Moo::Role;

# ABSTRACT: A job scheduling role for Mesos frameworks

=head1 NAME

Mesos::Framework::JobScheduler - A job scheduling role for Mesos frameworks

=cut

has schedule => (
    is      => "ro",
    isa     => "Mesos::Framework::JobScheduler::Role::Schedule",
    builder => 1,
);
sub _build_schedule { Mesos::Framework::JobScheduler::Schedule->new }


1;
