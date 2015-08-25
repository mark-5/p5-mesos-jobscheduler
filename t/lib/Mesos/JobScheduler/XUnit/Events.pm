package Mesos::JobScheduler::XUnit::Events;
use Moose::Meta::Class;
use Test::LeakTrace qw(no_leaks_ok);
use Test::Class::Moose;
use namespace::autoclean;

sub handler {
    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => ['Moose::Object'],
        roles        => ['Mesos::JobScheduler::Role::Events'],
        cache        => 1,
    );
    return $metaclass->new_object;
}

sub test_basic {
    my ($test)  = @_;
    my $handler = $test->handler;

    my $triggered = 0;
    $handler->on('wanted', sub { $triggered++ });

    $handler->trigger('not_wanted');
    is $triggered, 0, 'callback not triggered on unwanted event';

    $handler->trigger('wanted');
    is $triggered, 1, 'callback triggered on wanted event';


    my $second_trigger = 0;
    $handler->on('wanted', sub { $second_trigger++ });

    $triggered = 0;
    $handler->trigger('wanted');
    is $triggered, 1, 'triggered first callback when after adding second callback';
    is $second_trigger, 1, 'triggered second callback';
}

sub test_off {
    my ($test)  = @_;
    my $handler = $test->handler;

    my %triggered;
    my $first  = sub { $triggered{first}++  };
    my $second = sub { $triggered{second}++ };

    $handler->on('test-event', $first);
    $handler->on('test-event', $second);

    $handler->off('test-event', $first);
    $handler->trigger('test-event');
    ok !$triggered{first}, 'skipped first callback after turning it off explicitly';
    is $triggered{second}, 1, 'triggered second callback';

    %triggered = ();
    $handler->off('test-event');
    $handler->trigger('test-event');
    ok !%triggered, 'skipped all callbacks after calling off with only event name';
}

sub test_all {
    my ($test)  = @_;
    my $handler = $test->handler;

    my $called_all = 0;
    $handler->on('all', sub { $called_all++ });
    $handler->trigger('something random - '.rand);

    is $called_all, 1, 'callback registered for all triggered on random event';
}

sub test_namespaces {
    my ($test)  = @_;
    my $handler = $test->handler;

    my %triggered;
    $handler->on('ns',      sub { $triggered{ns}++   });
    $handler->on('ns:type', sub { $triggered{type}++ });

    $handler->trigger('ns:type');
    is $triggered{ns}, 1, 'triggered namespace for event with namespace and event';
    is $triggered{type}, 1, 'triggered type for event with matching namespace and type';

    %triggered = ();
    $handler->trigger('ns:different-type');
    ok !$triggered{type}, 'did not trigger type for event with matching namespace but different type';

    %triggered = ();
    $handler->trigger('ns');
    is $triggered{ns}, 1, 'triggered namespace for event with no type';
    ok !$triggered{type}, 'did not trigger type for event with matching namespace but no type';

    %triggered = ();
    $handler->trigger('different-ns:type');
    ok !$triggered{ns}, 'did not trigger namespace for event with different namespace';
    ok !$triggered{type}, 'did not trigger type for event with different namespace but matching type';
}

sub test_once {
    my ($test)  = @_;
    my $handler = $test->handler;

    my $triggered = 0;
    $handler->once('once', sub { $triggered++ });

    $handler->trigger('once');
    is $triggered, 1, 'triggered once event on first trigger';

    $triggered = 0;
    $handler->trigger('once');
    is $triggered, 0, 'did not trigger once event on second trigger';


    $triggered = 0;
    my $cb = sub { $triggered++ };
    $handler->once('once', $cb);
    $handler->off('once',  $cb);

    $handler->trigger('once');
    ok !$triggered. 'did not trigger once event after turning if off';
}

sub test_listen_to {
    my ($test)  = @_;
    my $handler  = $test->handler;
    my $listener = $test->handler;

    my %triggers;
    $listener->listen_to($handler, 'all', sub { $triggers{listener}++ });
    $handler->on('all', sub { $triggers{other}++ });

    $handler->trigger('event');
    is $triggers{listener}, 1, 'triggered event for callback from listen_to';
    is $triggers{other}, 1, 'triggered event for callback from on';

    %triggers = ();
    $listener->stop_listening;
    $handler->trigger('event');
    is $triggers{listener}, undef, 'did not trigger event for listen_to callback after stop_listening';
    is $triggers{other}, 1, 'triggered event for callback from on after unrelated listener stopped listening';
}

sub test_on_all {
    my ($test) = @_;
    my $handler = $test->handler;

    my @args_on_all;
    $handler->on('all', sub { @args_on_all = @_ });
    
    my $event = 'random-event-'.rand;
    my @args  = map rand, 1 .. int(rand 10);
    $handler->trigger($event, @args);
    is_deeply \@args_on_all, [$event, @args], 'all callback is triggered with event name and original args';
}

sub test_leaks {
    my ($test)  = @_;
    my $handler = $test->handler;

    no_leaks_ok {
        my $cb = sub {};
        $handler->once('event', $cb);
        $handler->trigger('event');
    } 'no leaks triggering once event';

    no_leaks_ok {
        my $cb = sub {};
        $handler->once('event', $cb);
        $handler->off('event',  $cb);
    } 'no leaks turning off once event';

    no_leaks_ok {
        my $cb       = sub {};
        my $listener = $test->handler;
        $listener->listen_to_once($handler, 'event', $cb);
        $handler->trigger('event');
    } 'no leaks triggering listen_to_once event';

    no_leaks_ok {
        my $cb       = sub {};
        my $listener = $test->handler;
        $listener->listen_to_once($handler, 'event', $cb);
        $listener->stop_listening;
    } 'no leaks turning off listen_to_once event';
}

__PACKAGE__->meta->make_immutable;
1;
