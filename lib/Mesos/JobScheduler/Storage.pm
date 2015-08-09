package Mesos::JobScheduler::Storage;

use Moo;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Interface::Storage';

has _storage => (
    is      => 'ro',
    default => sub { {} },
);

sub delete {
    my ($self, $node) = @_;
    return delete $self->_storage->{$node};
}

sub exists {
    my ($self, $node) = @_;
    return exists $self->_storage->{$node};
}

sub list {
    my ($self, $parent) = @_;
    $parent =~ s#/$##;
    return grep s#^$parent/([^/]+)/?#$1#, keys %{$self->_storage};
}

sub retrieve {
    my ($self, $node) = @_;
    return $self->_storage->{$node};
}

sub store {
    my ($self, $node, $data) = @_;
    $self->_storage->{$node} = $data;
}

sub update {
    my ($self, $node, $data) = @_;
    $self->_storage->{$node} = $data;
}

1;
