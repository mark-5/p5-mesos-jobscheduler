package Mesos::JobScheduler::Storage;

use Mesos::JobScheduler::Types qw(Config);
use Moose;
use namespace::autoclean;

has config => (
    is       => 'ro',
    isa      => Config['storage'],
    coerce   => 1,
    default  => sub { {} },
);

has root => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self)  = @_;
        my $default = '/mesos-jobscheduler';
        return $self->config->{root} // $default;
    },
);

has _elements => (
    is      => 'ro',
    default => sub { {} },
);

sub _abs {
    my ($self, $key) = @_;
    (my $root = $self->root) =~ s#/$##;
    $key = "$root/$key" unless $key =~ m#^/#;
    return $key
}

sub add {
    my ($self, $key, $value) = @_;
    my $abs = $self->_abs($key);
    $self->_elements->{$abs} = $value;
}

sub remove {
    my ($self, $key) = @_;
    my $abs = $self->_abs($key);
    return delete $self->_elements->{$abs};
}

sub get {
    my ($self, $key) = @_;
    my $abs = $self->_abs($key);
    return $self->_elements->{$abs};
}

sub get_children {
    my ($self, $key) = @_;
    my $abs   = $self->_abs($key);
    my @match = grep {m#^$abs/.*#} keys %{$self->_elements};
    my @nodes = map {$self->get($_)} @match;
    return @nodes;
}

sub update {
    my ($self, $key, $value) = @_;
    my $abs = $self->_abs($key);
    $self->_elements->{$abs} = $value;
}

__PACKAGE__->meta->make_immutable;
1;
