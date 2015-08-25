package Mesos::JobScheduler::Role::Events;

use Scalar::Util qw(weaken);
use Moose::Role;

has _event_callbacks => (
    is      => 'ro',
    default => sub { {} },
);

has _events_listening_to => (
    is      => 'ro',
    default => sub { {} },
);

sub on {
    my ($self, $event, $callback, %opts) = @_;
    my $cb_alias = $opts{cb_alias} // $callback;
    $self->_event_callbacks->{"$event#$cb_alias"} = $callback;
    return $cb_alias;
}

sub off {
    my ($self, $event, $callback) = @_;
    my $match  = join '#', grep defined, $event, $callback;
    my @events = grep {/^\Q$match\E/} keys %{$self->_event_callbacks};
    delete @{$self->_event_callbacks}{@events};
}

sub trigger {
    my ($self, $event, @args) = @_;

    # get callbacks for specific event
    my @events = grep {/^\Q$event\E#.*/} keys %{$self->_event_callbacks};
    # get callbacks for event namespace
    if (my ($ns) = $event =~ /^(.*?):/) {
        push @events, grep {/^\Q$ns\E#.*/} keys %{$self->_event_callbacks};
    }

    $_->(@args) for @{$self->_event_callbacks}{@events};
    for my $on_all (grep {/^all#.*/} keys %{$self->_event_callbacks}) {
        my $callback = $self->_event_callbacks->{$on_all};
        $callback->($event, @args);
    }
}

sub once {
    my ($self, $event, $_callback) = @_;
    weaken($self);

    my $callback; $callback = sub {
        $self->off($event, $_callback);
        goto &$_callback;
    };

    $self->on($event, $callback, cb_alias => $_callback);
    weaken($callback);

    return $_callback;
}

sub listen_to {
    my ($self, $other, $event, $callback, %opts) = @_;
    my $cb_alias = $opts{cb_alias} // $callback;

    $self->_events_listening_to->{"$other#$event#$cb_alias"} = [
        $other,
        $event,
        $callback,
    ];
    $other->on($event, $callback, %opts);

    return $cb_alias;
}

sub stop_listening {
    my ($self, $other, $event, $callback) = @_;
    my $match = join '#', grep defined, $other, $event, $callback;
    my @ids   = grep {/^\Q$match\E/} keys %{$self->_events_listening_to};
    for my $id (@ids) {
        my $listener = delete $self->_events_listening_to->{$id};
        my ($other, $event, $callback) = @$listener;
        $other->off($event, $callback);
    }
}

sub listen_to_once {
    my ($self, $other, $event, $_callback) = @_;
    weaken($self);

    my $callback; $callback = sub {
        $self->stop_listening($other, $event, $_callback);
        goto &$_callback;
    };

    $self->listen_to($other, $event, $callback, cb_alias => $_callback);
    weaken($callback);

    return $_callback;
}

1;
