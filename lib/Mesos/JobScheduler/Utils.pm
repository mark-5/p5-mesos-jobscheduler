package Mesos::JobScheduler::Utils;

use strict;
use warnings;
use DateTime;
use DateTime::Format::RFC3339;
use JSON qw();
use base 'Exporter::Tiny';
our @EXPORT_OK = qw(
    decode_json
    encode_json
    now
    psgi_json
);

sub now {
    my (%args) = @_;
    return DateTime->now(time_zone => 'UTC');
}

sub decode_json { goto &JSON::decode_json }

sub encode_json {
    my ($object, $opts) = @_;
    local *DateTime::TO_JSON = sub {
        return DateTime::Format::RFC3339->format_datetime($_[0]);
    } unless DateTime->can('TO_JSON');
    return JSON::to_json($object, {
        allow_blessed   => 1,
        allow_nonref    => 1,
        canonical       => 1,
        convert_blessed => 1,
        %{$opts||{}},
    });
}

sub psgi_json {
    my ($object, $opts) = @_;
    $opts = {map {($_ => $opts->{$_})x!! $opts->{$_}} keys %{$opts||{}}};
    my $status = delete $opts->{status} // 200;

    return [
        $status,
        ['Content-Type' => 'application/json'],
        [encode_json($object, $opts)],
    ],
}

1;
