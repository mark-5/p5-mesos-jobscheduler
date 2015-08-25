package Mesos::JobScheduler::XUnit::Executioner;
use Test::Class::Moose;
use namespace::autoclean;
extends 'Mesos::JobScheduler::XUnit';
with 'Mesos::JobScheduler::XUnit::Role::JobFactory';

sub new_executioner {
    my ($test)  = @_;
    return $test->resolve(service => 'executioner');
}

sub test_lifecycle {
    my ($test) = @_;
    my $executioner = $test->new_executioner;
    my $job         = $test->new_job;

    my $to_finish = $executioner->queue($job);
    is $executioner->get($to_finish->id)->status, 'queued';

    $executioner->start($to_finish->id);
    is $executioner->get($to_finish->id)->status, 'started';

    $executioner->finish($to_finish->id);
    is $executioner->get($to_finish->id), undef;

    my $to_fail = $executioner->queue($job);
    $executioner->start($to_fail->id);
    $executioner->fail($to_fail->id);
    is $executioner->get($to_fail->id), undef;
}

sub test_queued {
    my ($test) = @_;
    my $executioner = $test->new_executioner;
    is scalar $executioner->queued, 0, 'queue initially empty';

    my $first = $test->new_job;
    $executioner->queue($first);
    my @queued = $executioner->queued;
    is scalar @queued, 1, 'queue has 1 item after queuing first job';
    is $queued[0]->job_id, $first->id;

    my $second = $test->new_job;
    $executioner->queue($second);
    @queued = $executioner->queued;
    is scalar @queued, 2, 'queue has 2 items after queuing second job';
    is $queued[0]->job_id, $first->id, 'first execution matches first job after queuing second job';
    is $queued[1]->job_id, $second->id, 'second execution matches second job after queuing second job';

    $executioner->start($queued[0]->id);
    @queued = $executioner->queued;
    is scalar @queued, 1, 'queue has 1 item after starting first job';
    is $queued[0]->job_id, $second->id;
}

__PACKAGE__->meta->make_immutable;
1;
