package Mesos::Framework::JobScheduler::Role::Job;
use Types::Standard qw(Enum Str);
use Moo::Role;

=head1 NAME

Mesos::Framework::JobScheduler::Role::Job

=head1 ATTRIBUTES

=head2 name

=head2 status

=head2 executor

=head1 METHODS

=head2 on_update($schedule, $old_job)

=head2 on_registered($schedule)

=head2 on_deregistered($schedule)

=head2 on_terminated($task_status, $schedule)

Triggered on all task termination events(finished, failed, killed, lost).

=cut

my @statuses = qw(registered ready disabled deregistered);
has status => (
    is  => 'rw',
    isa => Enum[@statuses],
);

has name => (is => 'rw', isa => Str, required => 1);

has executor => (is => 'rw', required => 1);


1;
