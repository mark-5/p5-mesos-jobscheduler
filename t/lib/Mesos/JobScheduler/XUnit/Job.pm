package Mesos::JobScheduler::XUnit::Job;
use Mesos::JobScheduler::XUnit::Utils qw(new_job);
use Test::Class::Moose;
use namespace::autoclean;

sub test_job_updates {
    my ($test) = @_;
    my $job = new_job();

    my $new_job = $job->update(name => 'a new name');
    isnt $new_job->name, $job->name, 'name update does not change old job';
    is   $new_job->id,   $job->id,   'name update does not create new id';
}

__PACKAGE__->meta->make_immutable;
1;
