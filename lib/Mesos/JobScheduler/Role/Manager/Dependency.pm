package Mesos::JobScheduler::Role::Manager::Dependency;
use Mesos::JobScheduler::Utils qw(now);
use Moo::Role;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::Interface::Executioner
    Mesos::JobScheduler::Role::Interface::Registrar
);

has _job_dependencies => (
    is      => 'ro',
    default => sub { {} },
);

has _parent_jobs => (
    is      => 'ro',
    default => sub { {} },
);

sub _add_job_dependency {
    my ($self, $job) = @_;
    my $dependency = $self->_job_dependencies->{$job->id} = {
        added  => now(),
        job    => $job,
        parent => $job->parent,
    };
    $self->_parent_jobs->{$job->parent}{$job->id} = $dependency;
}

sub _remove_job_dependency {
    my ($self, $id) = @_;
    my $dependency = delete $self->_job_dependencies->{$id} or return;
    delete $self->_parent_jobs->{$dependency->{parent}};
}

sub _is_job_dependency {
    my ($self, $id_or_job) = @_;
    my $job = ref $id_or_job ? $id_or_job : $self->get_job($id_or_job);
    return $job && $job->isa('Mesos::JobScheduler::Job::Dependency');
}

after add_job => sub {
    my ($self, $job) = @_;
    return unless $self->_is_job_dependency($job);

    $self->_add_job_dependency($job);
};

around update_job => sub {
    my ($orig, $self, $id, %args) = @_;
    my $new = $self->$orig($id, %args);

    if ($self->_is_job_dependency($id)) {
        $self->_remove_job_dependency($id);
        $self->_add_job_dependency($new);
    }

    return $new;
};

before remove_job => sub {
    my ($self, $id) = @_;
    return unless $self->_is_job_dependency($id);

    $self->_remove_job_dependency($id);
};

before finish_execution => sub {
    my ($self, $execution_id) = @_;
    my $execution = $self->get_execution($execution_id);
    my $parent    = $execution->{job};

    for my $dependency (values %{$self->_parent_jobs->{$parent->id}||{}}) {
        $self->queue_execution($dependency->{job});
    }
};

1;
