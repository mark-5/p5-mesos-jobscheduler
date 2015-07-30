package Mesos::JobScheduler::Job::OneOff;
use Moo;
use Mesos::JobScheduler::Utils qw(now);
extends 'Mesos::JobScheduler::Job';
use namespace::autoclean;

=head1 ATTRIBUTES

=head2 scheduled

=cut

has scheduled => (
    is      => 'ro',
    default => sub { now() },
);

1;
