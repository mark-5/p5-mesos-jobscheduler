package Mesos::JobScheduler::Role::Interface::Registrar;
use Moo::Role;
with 'Mesos::JobScheduler::Role::Interface';

=head1 METHODS

=head2 add_job

=head2 get_job

=head2 remove_job

=head2 update_job

=cut

requires qw(
    add_job
    get_job
    remove_job
    update_job
);

1;
