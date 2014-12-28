package Mesos::Framework::JobScheduler::Role::Job::HasDependency;
use Types::Standard qw(Str);
use Moo::Role;
with "Mesos::Framework::JobScheduler::Role::Job";

=head1 NAME

Mesos::Framework::JobScheduler::Role::Job::HasDependency

=head1 ATTRIBUTES

=head2 dependency

=cut


has dependency => (
    is       => "rw",
    isa      => Str,
    required => 1,
);


1;
