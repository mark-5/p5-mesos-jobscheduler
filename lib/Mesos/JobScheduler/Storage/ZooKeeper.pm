package Mesos::JobScheduler::Storage::ZooKeeper;

use Mesos::JobScheduler::Utils qw(decode_json encode_json);
use Try::Tiny;
use ZooKeeper::Constants qw(ZNONODE);
use Moose;
use namespace::autoclean;
extends 'Mesos::JobScheduler::Storage';

has zk => (
    is       => 'ro',
    required => 1,
);

sub _ensure_parent {
    my ($self, $node) = @_;
    return if $self->zk->exists($node);

    my ($parent) = $node =~ m#(.+)/[^/]+# or return;
    if (not $self->zk->exists($parent)) {
        $self->_ensure_parent($parent);
        $self->zk->create($parent);
    }
}

sub _abs {
    my ($self, $node) = @_;
    (my $root = $self->root) =~ s#/$##;
    $node = "$root/$node" unless $node =~ m#^/#;
    return $node;
}

sub add {
    my ($self, $node, $data) = @_;
    my $abs = $self->_abs($node);
    $self->_ensure_parent($abs);
    $self->zk->create($abs, value => encode_json($data));
}

sub get {
    my ($self, $node) = @_;
    my $abs = $self->_abs($node);
    return decode_json(scalar $self->zk->get($abs));
}

sub get_children {
    my ($self, $node) = @_;
    my $abs = $self->_abs($node);
    return try {
        my @nodes = $self->zk->get_children($abs);
        return map {$self->get("$abs/$_")} @nodes;
    } catch {
        die unless $_ == ZNONODE;
        return;
    };
}

sub remove {
    my ($self, $node) = @_;
    my $abs = $self->_abs($node);
    my $old = $self->get($abs);
    $self->zk->delete($abs);
    return $old;
}

sub update {
    my ($self, $node, $data) = @_;
    my $abs = $self->_abs($node);
    $self->zk->set($abs => encode_json($data));
}

__PACKAGE__->meta->make_immutable;
1;
