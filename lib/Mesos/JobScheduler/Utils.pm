package Mesos::JobScheduler::Utils;
use strict;
use warnings;
use DateTime;
use JSON;
use base 'Exporter::Tiny';
our @EXPORT_OK = qw(now psgi_json);

sub now {
    my (%args) = @_;
    return DateTime->now(time_zone => 'UTC');
}

sub _json_parser {
    our $_json_parse;
    return $_json_parse //= do {
        JSON->new
            ->canonical(1)
            ->allow_blessed(1)
            ->convert_blessed(1)
    };
}

sub psgi_json {
    my ($object, $status) = @_;
    my $parser = _json_parser();
    return [
        $status // 200,
        ['Content-Type' => 'application/json'],
        [$parser->encode($object)],
    ],
}

1;
