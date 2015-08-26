package Mesos::JobScheduler::Registry;

use Mesos::JobScheduler::Types qw(to_Job);
use Moose;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Events';

has logger => (
    is       => 'ro',
    required => 1,
);

has storage => (
    is       => 'ro',
    required => 1,
);

sub all {
    my ($self) = @_;
    my @jobs =
        sort { $a->created <=> $b->created }
        map  { to_Job $_                   }
        $self->storage->get_children('registry');
    return @jobs;
}

sub add {
    my ($self, $job) = @_;
    $self->storage->add('registry/'.$job->id, $job);
    $self->logger->info('added job '.$job->id);
    $self->trigger('add:'.$job->type, $job);
}

sub remove {
    my ($self, $id) = @_;
    my $job = $self->storage->remove("registry/$id");
    $self->logger->info("removed job $id");
    $self->trigger('remove:'.$job->type, $job);
    return $job;
}

sub get {
    my ($self, $id) = @_;
    return to_Job $self->storage->get("registry/$id");
}

sub update {
    my ($self, $id, %args) = @_;
    my $old = $self->get($id);
    my $new = $old->update(%args);
    $self->storage->update("registry/$id", $new);
    $self->logger->info("updated job $id");
    $self->trigger('update:'.$new->type, $new, $old);
    return $new;
}

__PACKAGE__->meta->make_immutable;
1;
