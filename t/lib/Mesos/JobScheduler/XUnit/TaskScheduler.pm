package Mesos::JobScheduler::XUnit::TaskScheduler;
use Mesos::Messages;
use Moose::Meta::Attribute;
use Moose::Meta::Class;
use Test::Class::Moose;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::XUnit::Role::JobCreator
);

sub new_driver {
    my ($test, %methods) = @_;
    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [qw(Moose::Object)],
        methods      => \%methods,
    );
    return $metaclass->new_object;
}

sub new_offer {
    my ($test, %args) = @_;
    $args{resources} //= {mem => 128, cpus => 0.1, disk => 256};

    my $offer = {};
    $offer->{id} = {value => $args{id} // 'test-offer-'.rand};
    $offer->{framework_id} = {value => $args{framework_id} // 'test-framework-'.rand};
    $offer->{slave_id} = {value => $args{slave_id} // 'test-slave-'.rand};
    $offer->{hostname} = {value => $args{hostname} // 'test-host-'.rand};
    for my $name (keys %{$args{resources}||{}}) {
        my $value = $args{resources}{$name};
        push @{$offer->{resources}||=[]}, {
            name   => $name,
            type   => Mesos::Value::Type::SCALAR,
            scalar => {value => $value},
        }
    }
    return Mesos::Offer->new($offer);
}

sub new_scheduler {
    my ($test, %methods) = @_;
    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [qw(Mesos::Scheduler)],
        roles        => [qw(Mesos::JobScheduler::Role::Core)],
        methods      => \%methods,
    );
    return $metaclass->new_object;
}

sub test_basic_task_scheduling {
    my ($test) = @_;

    my $driver = $test->new_driver(
        launchTasks => sub { shift->{launchTasks} = \@_ },
    );
    my $scheduler = $test->new_scheduler;
    my $job       = $test->new_job;

    $scheduler->queue_execution($job);
    my $offer = $test->new_offer;
    $scheduler->resourceOffers($driver, [$offer]);

    my ($offer_id, $tasks) = @{$driver->{launchTasks}||[]};
    is scalar(@$tasks), 1, 'launched 1 task after queueing 1 execution';
    is_deeply $offer_id, $offer->{id}, 'launched offer with matching id';
    is $tasks->[0]->{command}{value}, $job->command, 'launched task with command from job';
}

sub test_offer_matching_priorities {
    my ($test) = @_;
    my $driver = $test->new_driver(
        launchTasks => sub { shift->{launchTasks} = \@_ },
    );
    my $scheduler = $test->new_scheduler;

    my $high  = $test->new_job(command => 'high priority');
    my $low   = $test->new_job(command => 'low priority');
    my $offer = $test->new_offer(resources => $high->resources);

    $scheduler->queue_execution($high);
    $scheduler->queue_execution($low);
    $scheduler->resourceOffers($driver, [$offer]);

    my ($offer_id, $tasks) = @{$driver->{launchTasks}||[]};
    is scalar(@$tasks), 1, 'launched 1 task when resources only allow 1';
    is $tasks->[0]->{command}{value}, $high->command, 'launched first queued execution';
}

sub test_offer_matching_partial_resources {
    my ($test) = @_;
    my $driver = $test->new_driver(
        launchTasks => sub { shift->{launchTasks} = \@_ },
    );
    my $scheduler = $test->new_scheduler;

    my $not_enough = $test->new_job(
        command   => 'not enough resources',
        resources => {mem => 10**6},
    );
    my $enough = $test->new_job(
        command   => 'enough resources',
        resources => {mem => 1},
    );
    my $offer = $test->new_offer(resources => $enough->resources);

    $scheduler->queue_execution($not_enough);
    $scheduler->queue_execution($enough);
    $scheduler->resourceOffers($driver, [$offer]);

    my ($offer_id, $tasks) = @{$driver->{launchTasks}||[]};
    is scalar(@$tasks), 1, 'launched 1 task when resources only allow 1';
    is $tasks->[0]->{command}{value}, $enough->command, 'only launched task with allowed resources';
}

__PACKAGE__->meta->make_immutable;
1;
