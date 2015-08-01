package Mesos::JobScheduler::Role::Interface::Logger;
use Moo::Role;
use namespace::autoclean;

=head1 METHODS

=head2 log

=head2 log_debug

=head2 log_info

=head2 log_error

=head2 log_fatal

=cut

requires qw(
    log
    log_debug
    log_info
    log_error
    log_fatal
);

1;
