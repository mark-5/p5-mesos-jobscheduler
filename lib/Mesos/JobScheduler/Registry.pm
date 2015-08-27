package Mesos::JobScheduler::Registry;

use Mesos::JobScheduler::Types qw(to_Job);
use Moose;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Events';

has logger => (
    is => 'ro',
);

has storage => (
    is => 'ro',
);

sub create {
    my ($self, $job) = @_;
    $self->storage->create('registry/'.$job->id, $job);
    $self->trigger('create:'.$job->type, job => $job);
    $self->logger->info('created job '.$job->id);
}

sub retrieve {
    my ($self, $id) = @_;
    return to_Job $self->storage->retrieve("registry/$id");
}

sub delete {
    my ($self, $id) = @_;
    my $job = $self->storage->delete("registry/$id");
    $self->trigger('delete:'.$job->type, job => $job);
    $self->logger->info("deleted job $id");
    return $job;
}

sub update {
    my ($self, $new) = @_;
    my $old = $self->retrieve($new->id);
    $self->storage->update('registry/'.$new->id, $new);
    $self->trigger('update:'.$new->type, new => $new, old => $old);
    $self->logger->info('updated job '.$new->id);
    return $new;
}

__PACKAGE__->meta->make_immutable;
1;
