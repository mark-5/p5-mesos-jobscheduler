package Mesos::JobScheduler::XUnit::Role::DateFaker;
use DateTime;
use Sub::Override;
use Test::Class::Moose::Role;
use namespace::autoclean;

has _datetime_override => (
    is      => 'rw',
    default => sub { Sub::Override->new },
);

sub test_setup { shift->unfake_the_date }

sub fake_the_date {
    my ($test, %args) = @_;
    if (my $now = $args{now}) {
        $test->_datetime_override->replace('DateTime::now', sub { $now });
    }
}

sub unfake_the_date {
    my ($test) = @_;
    $test->_datetime_override(Sub::Override->new);
}

1;
