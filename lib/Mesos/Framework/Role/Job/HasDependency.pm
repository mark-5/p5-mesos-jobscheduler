package Mesos::Framework::Role::Job::HasDependency;
use Types::Standard qw(Str);
use Moo::Role;
with "Mesos::Framework::Role::Job";


has dependency => (
    is       => "rw",
    isa      => Str,
    required => 1,
);


1;
