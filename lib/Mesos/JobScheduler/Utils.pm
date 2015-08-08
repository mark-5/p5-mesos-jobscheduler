package Mesos::JobScheduler::Utils;

use strict;
use warnings;
use DateTime;
use JSON qw();
use Mesos::JobScheduler::DateTime;
use Time::HiRes qw();
use base 'Exporter::Tiny';
our @EXPORT_OK = qw(
    decode_json
    encode_json
    now
    psgi_json
);

sub now { Mesos::JobScheduler::DateTime->now(@_) }

sub decode_json { goto &JSON::decode_json }

sub encode_json {
    my ($object, $opts) = @_;
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
    $opts = {%$opts};
    my $status = delete $opts->{status} // 200;

    return [
        $status,
        ['Content-Type' => 'application/json'],
        [encode_json($object, $opts)],
    ],
}

1;
