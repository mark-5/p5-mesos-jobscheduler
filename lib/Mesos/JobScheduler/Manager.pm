package Mesos::JobScheduler::Manager;

use Mesos::JobScheduler::Types qw(Config);
use Module::Runtime qw(require_module);
use Scalar::Util qw(weaken);
use Moose;
use namespace::autoclean;
with qw(
    Backbone::Events
    MooseX::Traits::Pluggable
);

# ABSTRACT: manage executions for different job types

=head1 METHODS

=head2 all_jobs

=head2 add_job

=head2 get_job

=head2 remove_job

=head2 update_job

=head2 all_executions

=head2 fail_execution

=head2 finish_execution

=head2 get_execution

=head2 queue_execution

=head2 queued

=head2 start_execution

=cut

has '+_trait_namespace' => (
    default => '+Traits',
);

has event_loop => (
    is       => 'ro',
    required => 1,
);

has executioner => (
    is      => 'ro',
    handles => {
        all_executions   => 'all',
        fail_execution   => 'fail',
        finish_execution => 'finish',
        get_execution    => 'get',
        queue_execution  => 'queue',
        queued           => 'queued',
        start_execution  => 'start',
    },
);

has registry => (
    is      => 'ro',
    handles => {
        add_job      => 'add',
        all_jobs     => 'all',
        get_job      => 'get',
        remove_job   => 'remove',
        update_job   => 'update',
    },
);

sub BUILD {
    my ($self) = @_;
    $self->attach_listeners;
}

sub attach_listeners {
    weaken(my $self = shift);
    # proxy all executioner and registry events
    $self->listen_to($self->$_, 'all', sub {
        my ($event, @args) = @_;
        $self->trigger($event, @args);
    }) for qw(executioner registry);
}

sub DEMOLISH {
    my ($self) = @_;
    $self->stop_listening($self->$_) for qw(executioner registry);
}

__PACKAGE__->meta->make_immutable;
1;
