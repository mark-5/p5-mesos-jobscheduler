package Mesos::JobScheduler::XUnit::Manager::Cron;
use Mesos::JobScheduler::Utils qw(now);
use Test::Class::Moose;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::XUnit::Role::DateFaker
    Mesos::JobScheduler::XUnit::Role::JobCreator
    Mesos::JobScheduler::XUnit::Role::ManagerCreator
);

sub test_adding_cron_job_for_now {
    my ($test)  = @_;
    my $cron    = $test->new_job('Cron', crontab => '0-59/5 * * * *');
    my $manager = $test->new_manager('Cron');
    $test->fake_the_date(now => now()->set_minute(0));

    $manager->add_job($cron);
    is scalar($manager->queued), 1, 'queue has item after adding job scheduled for now';
}

sub test_queueing_cron_job {
    my ($test)  = @_;
    my $cron    = $test->new_job('Cron', crontab => '0-59/5 * * * *');
    my $manager = $test->new_manager('Cron');
    $test->fake_the_date(now => now()->set_minute(1));

    $manager->add_job($cron);
    is scalar($manager->queued), 0, 'queue is empty after adding job';

    $test->fake_the_date(now => now()->add(minutes => 1));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 0, 'queue is empty while job is not ready';

    $test->fake_the_date(now => now()->add(minutes => 3));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 1, 'queue has item after job is ready';

    my ($queued) = $manager->queued;
    is $queued->{job}->id, $cron->id, 'execution in queue has job with orignal id';

    $test->fake_the_date(now => now()->add(minutes => 5));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 2, 'queue has another item after cron repeats';

    my ($first, $second) = map $_->{job}, $manager->queued;
    is $first->id, $second->id, 'executions have jobs with same ids';
    cmp_ok $first->scheduled, '<', $second->scheduled, 'executions have jobs with different times';
}

sub test_update_cron_job {
    my ($test)  = @_;
    my $cron    = $test->new_job('Cron', crontab => '0-59/5 * * * *');
    my $manager = $test->new_manager('Cron');
    $test->fake_the_date(now => now()->set_minute(1));
    $manager->add_job($cron);

    $manager->update_job($cron->id, crontab => '0-59/10 * * * *');
    $test->fake_the_date(now => now()->add(minutes => 4));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 0, 'queue stays empty before updated job time';

    $test->fake_the_date(now => now()->add(minutes => 5));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 1, 'queue has item after updated job time';
}

sub test_remove_cron_job {
    my ($test)  = @_;
    my $cron    = $test->new_job('Cron', crontab => '0-59/5 * * * *');
    my $manager = $test->new_manager('Cron');
    $test->fake_the_date(now => now()->set_minute(1));
    $manager->add_job($cron);

    $manager->remove_job($cron->id);
    $test->fake_the_date(now => now()->add(minutes => 4));
    $manager->_reset_next_timer;
    is scalar($manager->queued), 0, 'queue stays empty after removing job';
}

__PACKAGE__->meta->make_immutable;
1;
