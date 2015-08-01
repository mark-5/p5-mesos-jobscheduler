package Mesos::JobScheduler::Role::Interface::Timer;

use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Interface';

=head1 METHODS

=head2 add_timer

=head2 remove_timer

=cut

requires qw(
    add_timer
    remove_timer
);

1;
