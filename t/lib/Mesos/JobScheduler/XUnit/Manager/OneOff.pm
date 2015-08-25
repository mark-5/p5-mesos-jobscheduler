package Mesos::JobScheduler::XUnit::Manager::OneOff;
use Mesos::JobScheduler::Utils qw(now);
use Test::Class::Moose;
use namespace::autoclean;
extends 'Mesos::JobScheduler::XUnit';
with qw(
    Mesos::JobScheduler::XUnit::Role::DateFaker
    Mesos::JobScheduler::XUnit::Role::JobFactory
);

sub new_manager {
    my ($test, @traits) = @_;
    return $test->resolve(
        parameters => {traits => \@traits},
        service    => 'manager',
    );
}

sub test_adding_one_off_for_now {
    my ($test)  = @_;
    my $job     = $test->new_job('OneOff', scheduled => now());
    my $manager = $test->new_manager('OneOff');

    $manager->add_job($job);
    is scalar($manager->queued), 1, 'queue has item after adding job scheduled for now';
}

sub test_queueing_one_off {
    my ($test)  = @_;
    my $job     = $test->new_job('OneOff',
        scheduled => now()->add(minutes => 5),
    );
    my $manager = $test->new_manager('OneOff');

    $manager->add_job($job);
    is scalar($manager->queued), 0, 'queue is empty after adding job';

    $test->fake_the_date(now()->add(minutes => 1));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 0, 'queue is empty while job is not ready';

    $test->fake_the_date(now()->add(minutes => 4));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 1, 'queue has item after job is ready';

    my ($queued) = $manager->queued;
    is $queued->job->id, $job->id, 'execution in queue has job with orignal id';

    $manager->finish_execution($queued->{id});
    is $manager->get_job($queued->job->id), undef;
}

sub test_execution_cleanup {
    my ($test) = @_;
    my $job     = $test->new_job('OneOff');
    my $manager = $test->new_manager('OneOff');
    $manager->add_job($job);

    my ($execution) = $manager->queued;
    $manager->finish_execution($execution->{id});
    is $manager->get_job($execution->job->id), undef, 'job is removed after execution';
}

sub test_update_one_off {
    my ($test)  = @_;
    my $job     = $test->new_job('OneOff',
        scheduled => now()->add(minutes => 1),
    );
    my $manager = $test->new_manager('OneOff');
    $manager->add_job($job);

    $manager->update_job($job->id, scheduled => now()->add(minutes => 5));
    $test->fake_the_date(now()->add(minutes => 4));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 0, 'queue stays empty before updated job time';

    $test->fake_the_date(now()->add(minutes => 5));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 1, 'queue has item after updated job time';
}

sub test_remove_one_off {
    my ($test)  = @_;
    my $job     = $test->new_job('OneOff',
        scheduled => now()->add(minutes => 5),
    );
    my $manager = $test->new_manager('OneOff');
    $manager->add_job($job);

    $manager->remove_job($job->id);
    $test->fake_the_date(now()->add(minutes => 5));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 0, 'queue stays empty after removing job';
}

sub test_suspending_one_off_job {
    my ($test)  = @_;
    my $job     = $test->new_job('OneOff',
        scheduled => now()->add(minutes => 5),
    );
    my $manager = $test->new_manager('OneOff');
    $manager->add_job($job);

    $manager->update_job($job->id, suspended => 1);
    $test->fake_the_date(now()->add(minutes => 5));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 0, 'queue stays empty after suspending job';

    $manager->update_job($job->id, suspended => 0);
    is scalar($manager->queued), 1, 'queue has 1 entry after resuming job';
}

__PACKAGE__->meta->make_immutable;
1;
