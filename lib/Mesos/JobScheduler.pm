package Mesos::JobScheduler;
use Moo::Role;

# ABSTRACT: A job scheduling role for Mesos frameworks

=head1 NAME

Mesos::JobScheduler - A job scheduling role for Mesos frameworks

=cut

has schedule => (
    is      => "ro",
    isa     => "Mesos::JobScheduler::Role::Schedule",
    builder => 1,
);
sub _build_schedule { Mesos::JobScheduler::Schedule->new }


1;
