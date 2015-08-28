package Mesos::JobScheduler::Utils;

use strict;
use warnings;
use Carp qw(croak);
use JSON qw();
use Mesos::JobScheduler::DateTime;
use Module::Pluggable::Object;
use base 'Exporter::Tiny';

our @EXPORT_OK = qw(
    decode_json
    encode_json
    find_traits
    now
);

=head1 FUNCTIONS

=head2 decode_json

=head2 encode_json

=head2 find_traits

=head2 now

=cut

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

sub find_traits {
    my ($class) = @_;

    my $attr    = $class->meta->find_attribute_by_name('_trait_namespace');
    my $default = $attr->default
        or croak "Class $class must define a default _trait_namespace";
    $default = $default->() if ref $default eq 'CODE';
    $default =~ s/^\+(.*)/${class}::$1/;

    my $finder = Module::Pluggable::Object->new(
        search_path => [$default],
    );

    return grep s/^${default}:://, $finder->plugins;
}

sub now { Mesos::JobScheduler::DateTime->now(@_) }

1;
