package Mesos::JobScheduler::XUnit::Framework;
use Mesos::JobScheduler::XUnit::Utils qw(new_job);
use Mesos::Messages;
use Moose::Meta::Class;
use Test::Class::Moose;
use namespace::autoclean;
extends 'Mesos::JobScheduler::XUnit';

sub new_driver {
    my ($test, %methods) = @_;
    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [qw(Moose::Object)],
        methods      => \%methods,
    );
    return $metaclass->new_object;
}

sub new_framework {
    my ($test, @traits) = @_;
    return $test->resolve(
        parameters => {traits => \@traits},
        service    => 'framework',
    );
}

sub new_offer {
    my ($test, %args) = @_;
    $args{resources} //= {mem => 128, cpus => 0.1, disk => 256};

    my $offer = {
        id           => {value => $args{id}           // 'test-offer'},
        framework_id => {value => $args{framework_id} // 'test-framework'},
        slave_id     => {value => $args{slave_id}     // 'test-slave'},
        hostname     => {value => $args{hostname}     // 'test-host'},
    };
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

sub test_basic_task_scheduling {
    my ($test) = @_;

    my $driver = $test->new_driver(
        launchTasks => sub { shift->{launchTasks} = \@_ },
    );
    my $framework = $test->new_framework;
    my $job       = new_job();

    $framework->queue_execution($job);
    my $offer = $test->new_offer;
    $framework->resourceOffers($driver, [$offer]);

    my ($offer_ids, $tasks) = @{$driver->{launchTasks}||[]};
    is scalar(@$tasks), 1, 'launched 1 task after queueing 1 execution';
    is_deeply $offer_ids->[0], $offer->{id}, 'launched offer with matching id';
    is $tasks->[0]->{command}{value}, $job->command, 'launched task with command from job';
}

sub test_offer_matching_priorities {
    my ($test) = @_;
    my $driver = $test->new_driver(
        launchTasks => sub { shift->{launchTasks} = \@_ },
    );
    my $framework = $test->new_framework;

    my $high  = new_job(command => 'high priority');
    my $low   = new_job(command => 'low priority');
    my $offer = $test->new_offer(resources => $high->resources);

    $framework->queue_execution($high);
    $framework->queue_execution($low);
    $framework->resourceOffers($driver, [$offer]);

    my ($offer_id, $tasks) = @{$driver->{launchTasks}||[]};
    is scalar(@$tasks), 1, 'launched 1 task when resources only allow 1';
    is $tasks->[0]->{command}{value}, $high->command, 'launched first queued execution';
}

sub test_offer_matching_partial_resources {
    my ($test) = @_;
    my $driver = $test->new_driver(
        launchTasks => sub { shift->{launchTasks} = \@_ },
    );
    my $framework = $test->new_framework;

    my $not_enough = new_job(
        command   => 'not enough resources',
        resources => {mem => 10**6},
    );
    my $enough = new_job(
        command   => 'enough resources',
        resources => {mem => 1},
    );
    my $offer = $test->new_offer(resources => $enough->resources);

    $framework->queue_execution($not_enough);
    $framework->queue_execution($enough);
    $framework->resourceOffers($driver, [$offer]);

    my ($offer_id, $tasks) = @{$driver->{launchTasks}||[]};
    is scalar(@$tasks), 1, 'launched 1 task when resources only allow 1';
    is $tasks->[0]->{command}{value}, $enough->command, 'only launched task with allowed resources';
}

__PACKAGE__->meta->make_immutable;
1;
