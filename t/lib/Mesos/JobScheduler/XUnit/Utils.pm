package Mesos::JobScheduler::XUnit::Utils;
use strict;
use warnings;
use DateTime;
use Sub::Override;
use Symbol qw(qualify_to_ref);
use base 'Exporter::Tiny';
our @EXPORT_OK = qw(fake_the_date unfake_the_date);

our %_overrides;

sub fake_the_date {
    my (%args) = @_;
    if (my $now = $args{now}) {
        my $override = $_overrides{'DateTime'} //= Sub::Override->new;
        $override->replace('DateTime::now', sub { $now });
    }
}

sub unfake_the_date {
    delete $_overrides{'DateTime'};
}

1;
