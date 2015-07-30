package Mesos::JobScheduler::Job::Dependency;
use Moo;
use namespace::autoclean;
extends 'Mesos::JobScheduler::Job';

=head1 ATTRIBUTES

=head2 parent

=cut

has parent => (
    is       => 'ro',
    required => 1,
);

1;
