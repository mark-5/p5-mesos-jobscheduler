package Mesos::JobScheduler::XUnit::Registration;
use Mesos::JobScheduler::Job;
use Moose::Meta::Class;
use Test::Class::Moose;
use namespace::autoclean;
with 'Mesos::JobScheduler::XUnit::Role::JobCreator';

sub new_registry {
    my ($test, @args) = @_;
    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [qw(Moose::Object)],
        roles        => [qw(Mesos::JobScheduler::Role::Core)],
        cache        => 1,
    );
    return $metaclass->new_object(@args);
}

sub test_adding_job {
    my ($test)   = @_;
    my $registry = $test->new_registry;

    my $job = $test->new_job;
    $registry->add_job($job);
    
    my $registered = $registry->get_job($job->id);;
    is $job->id, $registered->id, 'retrieved job preserved id';
}

sub test_removing_job {
    my ($test)   = @_;
    my $registry = $test->new_registry;

    my $job = $test->new_job;
    $registry->add_job($job);

    $registry->remove_job($job->id);
    is $registry->get_job($job->id), undef, 'could not retrieve job from registry after removal';
}

sub test_updating_job {
    my ($test)   = @_;
    my $registry = $test->new_registry;

    my $job = $test->new_job;
    $registry->add_job($job);

    my $old_name = $job->name;
    my $new_name = 'some different name';
    $registry->update_job($job->id, name => $new_name);
    my $new = $registry->get_job($job->id);

    is $new->id,   $job->id,  'updated job preserved id';
    is $new->name, $new_name, 'updated job has updated name';
    is $job->name, $old_name, 'old job has old name';
}

__PACKAGE__->meta->make_immutable;
1;
