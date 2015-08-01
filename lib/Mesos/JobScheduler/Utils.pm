package Mesos::JobScheduler::Utils;

use strict;
use warnings;
use DateTime;
use DateTime::Format::RFC3339;
use JSON qw(to_json);
use base 'Exporter::Tiny';
our @EXPORT_OK = qw(now psgi_json);

sub now {
    my (%args) = @_;
    return DateTime->now(time_zone => 'UTC');
}

sub psgi_json {
    my ($object, $opts) = @_;
    $opts = {map {($_ => $opts->{$_})x!! $opts->{$_}} keys %{$opts||{}}};
    my $status = delete $opts->{status} // 200;

    local *DateTime::TO_JSON = sub {
        return DateTime::Format::RFC3339->format_datetime($_[0]);
    } unless DateTime->can('TO_JSON');

    return [
        $status,
        ['Content-Type' => 'application/json'],
        [to_json($object, {
            canonical       => 1,
            allow_blessed   => 1,
            convert_blessed => 1,
            %$opts,
        })],
    ],
}

1;
