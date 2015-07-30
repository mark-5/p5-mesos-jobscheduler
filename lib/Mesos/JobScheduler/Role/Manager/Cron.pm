package Mesos::JobScheduler::Role::Manager::Cron;
use Mesos::JobScheduler::Utils qw(now);
use Scalar::Util qw(weaken);
use Moo::Role;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::Interface::EventLoop
    Mesos::JobScheduler::Role::Interface::Registrar
    Mesos::JobScheduler::Role::Interface::Executioner
    Mesos::JobScheduler::Role::Interface::Timer
);

sub test_setup { unfake_the_date() }

sub _add_cron_job {
    my ($self, $job) = @_;
    $self->add_timer($job,
        cb => sub {
            my ($self, $job) = @_;
            $self->queue_execution($job);
            $self->update_job($job->id, scheduled => $job->next);
        },
        scheduled => $job->scheduled,
    );
}

sub _remove_cron_job {
    my ($self, $id) = @_;
    $self->remove_timer($id);
}

sub _is_cron_job {
    my ($self, $id_or_job) = @_;
    my $job = ref $id_or_job ? $id_or_job : $self->get_job($id_or_job);
    return $job && $job->isa('Mesos::JobScheduler::Job::Cron');
}


after add_job => sub {
    my ($self, $job) = @_;
    return unless $self->_is_cron_job($job);

    $self->_add_cron_job($job);
};

around update_job => sub {
    my ($orig, $self, $id, %args) = @_;
    my $new = $self->$orig($id, %args);

    if ($self->_is_cron_job($id)) {
        $self->_remove_cron_job($id);
        $self->_add_cron_job($new);
    }

    return $new;
};

before remove_job => sub {
    my ($self, $id) = @_;
    return unless $self->_is_cron_job($id);

    $self->_remove_cron_job($id);
};

1;
