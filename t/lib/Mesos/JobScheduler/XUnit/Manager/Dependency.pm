package Mesos::JobScheduler::XUnit::Manager::Dependency;
use Mesos::JobScheduler::XUnit::Utils qw(new_job);
use Test::Class::Moose;
use namespace::autoclean;
extends 'Mesos::JobScheduler::XUnit';

sub new_manager {
    my ($test, @traits) = @_;
    return $test->resolve(
        parameters => {traits => \@traits},
        service    => 'manager',
    );
}

sub test_dependency_queueing {
    my ($test) = @_;
    my $manager = $test->new_manager('Dependency');
    my $parent  = new_job();
    my $child   = new_job('Dependency',
        parent => $parent->id,
    );
    $manager->add_job($parent);
    $manager->add_job($child);

    my $parent_ex = $manager->queue_execution($parent);
    $manager->finish_execution($parent_ex->id);

    my @queued = $manager->queued;
    is scalar(@queued), 1, 'queue has item after completing parent job';
    is $queued[0]->job->command, $child->command, 'child job queued after parent execution finishes'
}

sub test_parent_job_failure {
    my ($test) = @_;
    my $manager = $test->new_manager('Dependency');
    my $parent  = new_job();
    my $child   = new_job('Dependency',
        parent => $parent->id,
    );
    $manager->add_job($parent);
    $manager->add_job($child);

    my $parent_ex = $manager->queue_execution($parent);
    $manager->fail_execution($parent_ex->id);
    is scalar($manager->queued), 0, 'no items queued after failing parent execution';
}

sub test_updating_dependency {
    my ($test) = @_;
    my $manager = $test->new_manager('Dependency');
    my $parent1 = new_job();
    my $parent2 = new_job();
    my $child   = new_job('Dependency',
        parent => $parent1->id,
    );
    $manager->add_job($parent1);
    $manager->add_job($parent2);
    $manager->add_job($child);

    my $parent1_ex = $manager->queue_execution($parent1);
    $manager->update_job($child->id, parent => $parent2->id);
    $manager->finish_execution($parent1_ex->id);
    is scalar($manager->queued), 0, 'didnt queue old parent after updating dependency';

    my $parent2_ex = $manager->queue_execution($parent2);
    $manager->finish_execution($parent2_ex->id);
    my @queued = $manager->queued;
    is scalar(@queued), 1, 'item queued after new parent executed';
    is $queued[0]->job->command, $child->command, 'queued dependency after new parent executed';
}

sub test_multiple_parent_executions {
    my ($test) = @_;
    my $manager = $test->new_manager('Dependency');
    my $parent  = new_job();
    my $child   = new_job('Dependency',
        parent => $parent->id,
    );
    $manager->add_job($parent);
    $manager->add_job($child);

    for (1 .. 3) {
        my $parent_ex = $manager->queue_execution($parent);
        $manager->finish_execution($parent_ex->id);
    }

    is scalar($manager->queued), 3, 'queue has 3 items after 3 parent executions';

    my $all_children = not grep {$_->job->command ne $child->command} $manager->queued;
    ok $all_children, 'all queued items are child jobs after parent executions';
}

sub test_removing_dependency {
    my ($test) = @_;
    my $manager = $test->new_manager('Dependency');
    my $parent  = new_job();
    my $child   = new_job('Dependency',
        parent => $parent->id,
    );
    $manager->add_job($parent);
    $manager->add_job($child);

    my $parent_ex = $manager->queue_execution($parent);
    $manager->remove_job($child->id);
    $manager->finish_execution($parent_ex->id);

    is scalar($manager->queued), 0, 'no items queued after removing job dependency';
}

sub test_suspending_dependency {
    my ($test) = @_;
    my $manager = $test->new_manager('Dependency');
    my $parent  = new_job();
    my $child   = new_job('Dependency',
        parent => $parent->id,
    );
    $manager->add_job($parent);
    $manager->add_job($child);

    my $parent_ex = $manager->queue_execution($parent);
    $manager->update_job($child->id, suspended => 1);
    $manager->finish_execution($parent_ex->id);

    is scalar($manager->queued), 0, 'no items queued after suspending job dependency';

    $parent_ex = $manager->queue_execution($parent);
    $manager->update_job($child->id, suspended => 0);
    $manager->finish_execution($parent_ex->id);

    is scalar($manager->queued), 1, '1 item queued after resuming job dependency';
}

__PACKAGE__->meta->make_immutable;
1;
