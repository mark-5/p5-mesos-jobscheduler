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
    ok !$triggered, 'callback not triggered on unwanted event';

    $handler->trigger('wanted');
    ok $triggered, 'callback triggered on unwanted event';


    my $second_trigger = 0;
    $handler->on('wanted', sub { $second_trigger++ });

    $triggered = 0;
    $handler->trigger('wanted');
    ok $triggered, 'triggered first callback when after adding second callback';
    ok $second_trigger, 'triggered second callback';
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
    ok $triggered{second}, 'triggered second callback';

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
    ok $triggered{ns}, 'triggered namespace for event with namespace and event';
    ok $triggered{type}, 'triggered type for event with matching namespace and type';

    %triggered = ();
    $handler->trigger('ns:different-type');
    ok !$triggered{type}, 'did not trigger type for event with matching namespace but different type';

    %triggered = ();
    $handler->trigger('ns');
    ok $triggered{ns}, 'triggered namespace for event with no type';
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
    ok $triggered, 'triggered once event on first trigger';

    $triggered = 0;
    $handler->trigger('once');
    ok !$triggered, 'did not trigger once event on second trigger';


    $triggered = 0;
    my $cb = sub { $triggered++ };
    $handler->once('once', $cb);
    $handler->off('once',  $cb);

    $handler->trigger('once');
    ok !$triggered. 'did not trigger once event after turning if off';
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
}

__PACKAGE__->meta->make_immutable;
1;
