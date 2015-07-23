package Mesos::JobScheduler::Role::HandlesManagerDispatching;
use Hash::Ordered;
use Moo::Role;
use namespace::autoclean;

has _managers => (
    is      => 'ro',
    default => sub { Hash::Ordered->new },
);

sub add_manager {
    my ($self, $manager) = @_;
    $self->_managers->push($manager->id => $manager);
    $manager->set_scheduler($self);
}

sub remove_manager {
    my ($self, $id) = @_;
    return $self->_managers->delete($id);
}

sub find_manager {
    my ($self, $job) = @_;
    for my $manager (reverse $self->_managers->values) {
        return $manager if $manager->filter($job);
    }
}

sub _generate_dispatch {
    my ($method) = @_;
    return sub {
        my ($self, $id_or_job, @args) = @_;
        my $job = ref $id_or_job ? $id_or_job : $self->get_job($id_or_job);

        my $manager = $self->find_manager($job) or return;
        return $manager->$method($id_or_job, @args);
    }
}

before $_ => _generate_dispatch($_) for qw(remove_job);

after $_  => _generate_dispatch($_) for qw(
    add_job

    queue_job
    start_job
    finish_job
    fail_job
);


1;
