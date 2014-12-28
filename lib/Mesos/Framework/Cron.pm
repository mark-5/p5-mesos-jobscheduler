package Mesos::Framework::Cron;
use Moo::Role;

# ABSTRACT: A cron scheduling role for Mesos frameworks

=head1 NAME

Mesos::Framework::Cron - A cron scheduling role for Mesos frameworks

=cut

has schedule => (
    is => "ro",
    isa => sub { shift->does("Mesos::Framework::Role::Schedule") },
    handles => [qw(register deregister)],
);


1;
