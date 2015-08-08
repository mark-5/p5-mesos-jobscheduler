package Mesos::JobScheduler::DateTime;

use strict;
use warnings;
use Class::Method::Modifiers;
use DateTime::Format::RFC3339;
use Time::HiRes qw();
use base 'DateTime';
use overload '""' => '_stringify';

sub _core_time { scalar Time::HiRes::time }

around from_epoch => sub {
    my ($orig, $class, @args) = @_;
    return $class->$orig(time_zone => 'UTC', @args);
};

around new => sub {
    my ($orig, $class, @args) = @_;
    return $class->now unless @args;
    return $class->$orig(@args);
};

sub now {
    my ($class, @args) = @_;
    return $class->from_epoch(epoch => $class->_core_time, @args);
}

sub _stringify { DateTime::Format::RFC3339->format_datetime($_[0]) }

sub TO_JSON { shift->_stringify }

1;
