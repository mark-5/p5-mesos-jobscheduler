package Mesos::JobScheduler::Utils;

use strict;
use warnings;
use JSON qw();
use Mesos::JobScheduler::DateTime;
use base 'Exporter::Tiny';

our @EXPORT_OK = qw(
    decode_json
    encode_json
    now
);

sub decode_json {
    my ($txt, $opts) = @_;
    return JSON::from_json($txt, {
        allow_nonref => 1,
        %{$opts||{}},
    });
}

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

sub now { Mesos::JobScheduler::DateTime->now(@_) }

1;
