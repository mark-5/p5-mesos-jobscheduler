package Mesos::JobScheduler::Role::Interface::Executioner;

use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Interface';

=head1 METHODS

=head2 get_execution

=head2 fail_execution

=head2 finish_execution

=head2 queue_execution

=head2 queued

=head2 start_execution

=cut

requires qw(
    executions
    queued

    get_execution
    queue_execution
    fail_execution
    finish_execution
    start_execution
);

1;
