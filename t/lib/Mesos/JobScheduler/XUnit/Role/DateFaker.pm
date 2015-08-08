package Mesos::JobScheduler::XUnit::Role::DateFaker;
use Mesos::JobScheduler::DateTime;
use Sub::Override;
use Test::Class::Moose::Role;
use namespace::autoclean;

has _date_override => (
    is      => 'rw',
    default => sub { Sub::Override->new },
);

sub test_setup { shift->unfake_the_date }

sub fake_the_date {
    my ($test, %args) = @_;
    if (my $now = $args{now}) {
        $test->_date_override->replace(
            'Mesos::JobScheduler::DateTime::_core_time',
            sub { $now->hires_epoch },
        );
    }
}

sub unfake_the_date {
    my ($test) = @_;
    $test->_date_override(Sub::Override->new);
}

1;
