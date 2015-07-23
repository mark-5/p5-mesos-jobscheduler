package Mesos::JobScheduler::XUnit::Executions;
use Moose::Meta::Class;
use Test::Class::Moose;
use namespace::autoclean;
with 'Mesos::JobScheduler::XUnit::Role::JobCreator';

sub new_executioner {
    my ($test, @args) = @_;
    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [qw(Moose::Object)],
        roles        => [qw(
            Mesos::JobScheduler::Role::HandlesRegistration
            Mesos::JobScheduler::Role::HandlesExecutions
        )],
        cache => 1,
    );
    return $metaclass->new_object(@args);
}

sub test_add_job {
    my ($test) = @_;
    my $executioner = $test->new_executioner;
    my $job = $test->new_job;

    $executioner->add_job($job);
    my $status = $executioner->get_status($job->id);
    is $status, 'registered';
}

sub test_remove_job {
    my ($test) = @_;
    my $executioner = $test->new_executioner;
    my $job = $test->new_job;

    $executioner->add_job($job);
    $executioner->remove_job($job->id);
    my $status = $executioner->get_status($job->id);
    is $status, undef;
}

sub test_status_transitions {
    my ($test) = @_;
    my $executioner = $test->new_executioner;
    my $job = $test->new_job;
    my $id  = $job->id;
    $executioner->add_job($job);

    my %transitions = (
        queue_job  => 'queued',
        start_job  => 'started',
        finish_job => 'finished',
        fail_job   => 'failed',
    );

    for my $transition (keys %transitions) {
        my $old_status = $executioner->get_status($id);
        $executioner->$transition($id);
        my $new_status = $executioner->get_status($id);

        isnt $new_status, $old_status;
        is   $new_status, $transitions{$transition};

        my ($new_id) = $executioner->$new_status;
        my ($old_id) = $executioner->$old_status;
        is $new_id, $id;
        is $old_id, undef;
    }
}

__PACKAGE__->meta->make_immutable;
1;
