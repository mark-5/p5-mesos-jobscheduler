package Mesos::JobScheduler::Storage::ZooKeeper;

use Mesos::JobScheduler::Utils qw(decode_json encode_json);
use Try::Tiny;
use ZooKeeper::Constants qw(ZNONODE);
use Moo;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::HasZooKeeper
    Mesos::JobScheduler::Role::Interface::Storage
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

sub delete {
    my ($self, $node) = @_;
    my $old = $self->retrieve($node);
    $self->zk->delete($node);
    return $old;
}

sub exists {
    my ($self, $node) = @_;
    return $self->zk->exists($node);
}

sub list {
    my ($self, $node) = @_;
    return try {
        $self->zk->get_children($node);
    } catch {
        die unless $_ == ZNONODE;
        return;
    };
}

sub retrieve {
    my ($self, $node) = @_;
    return decode_json(scalar $self->zk->get($node));
}

sub store {
    my ($self, $node, $data) = @_;
    $self->_ensure_parent($node);
    $self->zk->create($node, value => encode_json($data));
}

sub update {
    my ($self, $node, $data) = @_;
    $self->zk->set($node => encode_json($data));
}

1;
