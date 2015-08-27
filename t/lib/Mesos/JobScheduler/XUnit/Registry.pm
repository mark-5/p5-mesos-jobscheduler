package Mesos::JobScheduler::XUnit::Registry;
use Mesos::JobScheduler::Logger;
use Mesos::JobScheduler::Registry;
use Mesos::JobScheduler::Storage;
use Test::Class::Moose;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::XUnit::Role::JobFactory
    Mesos::JobScheduler::XUnit::Role::RegistryFactory
);

sub test_adding_job {
    my ($test)   = @_;
    my $registry = $test->new_registry;

    my $job = $test->new_job;
    $registry->create($job);
    
    my $registered = $registry->retrieve($job->id);
    is $job->id, $registered->id, 'retrieved job preserved id';
}

sub test_removing_job {
    my ($test)   = @_;
    my $registry = $test->new_registry;

    my $job = $test->new_job;
    $registry->create($job);

    $registry->delete($job->id);
    is $registry->retrieve($job->id), undef, 'could not retrieve job from registry after removal';
}

sub test_updating_job {
    my ($test)   = @_;
    my $registry = $test->new_registry;

    my $job = $test->new_job;
    $registry->create($job);

    my $old_name = $job->name;
    my $new_name = 'some different name';
    $registry->update($job->update(name => $new_name));
    my $new = $registry->retrieve($job->id);

    is $new->id,   $job->id,  'updated job preserved id';
    is $new->name, $new_name, 'updated job has updated name';
    is $job->name, $old_name, 'old job has old name';
}

__PACKAGE__->meta->make_immutable;
1;
