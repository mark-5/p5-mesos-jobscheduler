package Mesos::JobScheduler::Role::Interface::EventLoop;
use Moo::Role;
with 'Mesos::JobScheduler::Role::Interface';

=head1 METHODS

=head2 new_timer

=cut

requires qw(new_timer);

1;
