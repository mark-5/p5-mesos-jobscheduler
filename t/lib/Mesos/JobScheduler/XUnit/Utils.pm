package Mesos::JobScheduler::XUnit::Utils;
use strict;
use warnings;
use DateTime;
use Symbol qw(qualify_to_ref);
use base 'Exporter::Tiny';
our @EXPORT = qw(fake_the_date unfake_the_date);

our %_original_datetime_methods = (
    now => *{qualify_to_ref('now', 'DateTime')}{CODE},
);

sub fake_the_date {
    no warnings 'redefine';
    my (%args) = @_;
    if (my $now = $args{now}) {
        *{qualify_to_ref('now', 'DateTime')} = sub { $now };
    }
}

sub unfake_the_date {
    while (my ($name, $code) = each %_original_datetime_methods) {
        *{qualify_to_ref($name, 'DateTime')} = $code;
    }
}

1;
