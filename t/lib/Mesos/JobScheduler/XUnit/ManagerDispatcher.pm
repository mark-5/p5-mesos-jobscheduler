package Mesos::JobScheduler::XUnit::ManagerDispatcher;
use Moose::Meta::Attribute;
use Moose::Meta::Class;
use Test::Class::Moose;
use namespace::autoclean;
with 'Mesos::JobScheduler::XUnit::Role::JobCreator';

sub new_dispatcher {
    my ($test, @args) = @_;
    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [qw(Moose::Object)],
        roles        => [qw(
            Mesos::JobScheduler::Role::HandlesRegistration
            Mesos::JobScheduler::Role::HandlesExecutions
            Mesos::JobScheduler::Role::HandlesManagerDispatching    
        )],
        cache => 1,
    );
    return $metaclass->new_object(@args);
}

sub new_manager {
    my ($test, %methods) = @_;

    while (my ($name, $code) = each %methods) {
        next if $name eq 'filter';
        $methods{$name} = sub {
            my ($self, @args) = @_;
            $self->add_event([$name, @args]);
            return $code->(@_);
        }
    }

    $methods{add_event}    = sub { push @{$_[0]->events}, $_[1] };
    $methods{clear_events} = sub { @{shift->events} = () };
    $methods{last_event}   = sub { shift->events->[-1] };

    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [qw(Mesos::JobScheduler::Manager)],
        attributes   => [
            Moose::Meta::Attribute->new('events',
                is      => 'ro',
                default => sub { [] },
            ),
        ],
        methods => \%methods,
    );
    return $metaclass->new_object;
}

sub test_dispatching {
    my ($test) = @_;
    my $dispatcher = $test->new_dispatcher;

    my $handles_foo = $test->new_manager(
        filter => sub {
            my ($self, $job) = @_;
            return $job->name eq 'foo';
        },
        add_job => sub { },
    );
    $dispatcher->add_manager($handles_foo);
    my $foo_job = $test->new_job(name => 'foo');
    $dispatcher->add_job($foo_job);
    is $handles_foo->last_event->[0], 'add_job';
    is $handles_foo->last_event->[1]->id, $foo_job->id;

    $handles_foo->clear_events;
    my $handles_bar = $test->new_manager(
        filter => sub {
            my ($self, $job) = @_;
            return $job->name eq 'bar';
        },
        add_job => sub { },
    );
    $dispatcher->add_manager($handles_bar);
    my $bar_job = $test->new_job(name => 'bar');
    $dispatcher->add_job($bar_job);
    is $handles_bar->last_event->[0], 'add_job';
    is $handles_bar->last_event->[1]->id, $bar_job->id;
    is $handles_foo->last_event, undef;
}

__PACKAGE__->meta->make_immutable;
1;
