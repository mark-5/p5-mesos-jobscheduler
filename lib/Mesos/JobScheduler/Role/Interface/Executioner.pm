package Mesos::JobScheduler::Role::Interface::Executioner;
use Moo::Role;
use namespace::autoclean;

=head1 METHODS

=head2 fail_execution

=head2 finish_execution

=head2 queue_execution

=head2 queued

=head2 start_execution

=cut

requires qw(
    queued

    queue_execution
    fail_execution
    finish_execution
    start_execution
);

1;
