package Mesos::Framework::JobScheduler::Role::Job::HasDependency;
use Types::Standard qw(Str);
use Moo::Role;
with "Mesos::Framework::JobScheduler::Role::Job";


has dependency => (
    is       => "rw",
    isa      => Str,
    required => 1,
);


1;
