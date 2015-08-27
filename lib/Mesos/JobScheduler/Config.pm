package Mesos::JobScheduler::Config;

use Hash::Merge qw(merge);
use YAML qw(LoadFile);
use Moose;

has file => (
    is        => 'ro',
    predicate => '_has_file',
);

has _config_from_file => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_config_from_file',
);
sub _build_config_from_file {
    my ($self) = @_;
    return LoadFile($self->file);
}

has api => (
    is      => 'ro',
    default => sub { {} },
);

has logger => (
    is      => 'ro',
    default => sub { {} },
);

has storage => (
    is      => 'ro',
    default => sub { {} },
);

has zookeeper => (
    is      => 'ro',
    default => sub { {} },
);

sub BUILD {
    my ($self) = @_;
    return unless $self->_has_file;
    %$self = %{merge({%$self}, $self->_config_from_file)};
}

__PACKAGE__->meta->make_immutable;
1;
