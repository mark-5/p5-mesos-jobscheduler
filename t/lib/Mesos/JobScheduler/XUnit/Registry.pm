package Mesos::JobScheduler::XUnit::Registry;
use Mesos::JobScheduler::Logger;
use Mesos::JobScheduler::Registry;
use Mesos::JobScheduler::Storage;
use Mesos::JobScheduler::XUnit::Utils qw(new_job);
use Test::Class::Moose;
use namespace::autoclean;
extends 'Mesos::JobScheduler::XUnit';

sub new_registry {
    my ($test) = @_;
    return $test->resolve(service => 'registry');
}

sub test_adding_job {
    my ($test)   = @_;
    my $registry = $test->new_registry;

    my $job = new_job();
    $registry->add($job);
    
    my $registered = $registry->get($job->id);
    is $job->id, $registered->id, 'getd job preserved id';
}

sub test_removing_job {
    my ($test)   = @_;
    my $registry = $test->new_registry;

    my $job = new_job();
    $registry->add($job);

    $registry->remove($job->id);
    is $registry->get($job->id), undef, 'could not get job from registry after removal';
}

sub test_updating_job {
    my ($test)   = @_;
    my $registry = $test->new_registry;

    my $job = new_job();
    $registry->add($job);

    my $old_name = $job->name;
    my $new_name = 'some different name';
    $registry->update($job->id, name => $new_name);
    my $new = $registry->get($job->id);

    is $new->id,   $job->id,  'updated job preserved id';
    is $new->name, $new_name, 'updated job has updated name';
    is $job->name, $old_name, 'old job has old name';
}

__PACKAGE__->meta->make_immutable;
1;
