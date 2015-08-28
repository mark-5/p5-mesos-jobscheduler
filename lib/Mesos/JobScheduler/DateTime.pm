package Mesos::JobScheduler::DateTime;

use strict;
use warnings;
use Class::Method::Modifiers;
use DateTime::Format::RFC3339;
use Time::HiRes qw();
use base 'DateTime';
use overload '""' => '_stringify';

sub _core_time { scalar Time::HiRes::time }

=head1 DESCRIPTION

A DateTime subclass with saner defaults

=head1 DEFAULTS

=head2 stringification

Stringifies to a RFC3339 timestamp

=head2 time zone

Defaults to UTC

=head1 METHODS

=head2 parse_datetime

A class method to parse RFC3339 timestamps

=head2 TO_JSON

Defaults to stringifying itself

=cut

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

sub parse_datetime {
    my ($class, $stamp) = @_;
    my $obj = DateTime::Format::RFC3339->new->parse_datetime($_);
    return $class->from_object(object => $obj);
}

sub _stringify { DateTime::Format::RFC3339->format_datetime($_[0]) }

sub TO_JSON { shift->_stringify }

1;
