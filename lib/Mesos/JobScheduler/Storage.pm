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
    default => '/',
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

sub create {
    my ($self, $key, $value) = @_;
    my $abs = $self->_abs($key);
    $self->_elements->{$abs} = $value;
}

sub delete {
    my ($self, $key) = @_;
    my $abs = $self->_abs($key);
    return delete $self->_elements->{$abs};
}

sub retrieve {
    my ($self, $key) = @_;
    my $abs = $self->_abs($key);
    return $self->_elements->{$abs};
}

sub retrieve_children {
    my ($self, $key) = @_;
    my $abs   = $self->_abs($key);
    my @match = grep {s#^$abs/([^/]*)#$1#} keys %{$self->_elements};
    return @match;
}

sub update {
    my ($self, $key, $value) = @_;
    my $abs = $self->_abs($key);
    $self->_elements->{$abs} = $value;
}

__PACKAGE__->meta->make_immutable;
1;
