package Mesos::JobScheduler::Role::Manager::OneOff;
use Moo::Role;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::Interface::EventLoop
    Mesos::JobScheduler::Role::Interface::Executioner
    Mesos::JobScheduler::Role::Interface::Registrar
    Mesos::JobScheduler::Role::Interface::Timer
);

sub _add_one_off_job {
    my ($self, $job) = @_;
    $self->add_timer($job,
        cb => sub {
            my ($self, $job) = @_;
            $self->queue_execution($job);
        },
        scheduled => $job->scheduled,
    );
}

sub _remove_one_off_job {
    my ($self, $id) = @_;
    $self->remove_timer($id);
}

sub _is_one_off_job {
    my ($self, $id_or_job) = @_;
    my $job = ref $id_or_job ? $id_or_job : $self->get_job($id_or_job);
    return $job && $job->isa('Mesos::JobScheduler::Job::OneOff');
}

after add_job => sub {
    my ($self, $job) = @_;
    return unless $self->_is_one_off_job($job);

    $self->_add_one_off_job($job);
};

around update_job => sub {
    my ($orig, $self, $id, %args) = @_;
    my $new = $self->$orig($id, %args);

    if ($self->_is_one_off_job($id)) {
        $self->_remove_one_off_job($id);
        $self->_add_one_off_job($new);
    }

    return $new;
};

before remove_job => sub {
    my ($self, $id) = @_;
    return unless $self->_is_one_off_job($id);

    $self->_remove_one_off_job($id);
};

around $_ => sub {
    my ($orig, $self, $execution_id) = @_;
    my $execution = $self->$orig($execution_id);

    if ($self->_is_one_off_job($execution->{job})) {
        $self->remove_job($execution->{job}->id);
    }

    return $execution;
} for qw(finish_execution fail_execution);

1;
