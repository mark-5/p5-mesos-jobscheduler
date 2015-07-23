package Mesos::JobScheduler::Role::HandlesExecutions;
use Hash::Ordered;
use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Interface::Executioner';

has _id_to_status => (
    is      => 'ro',
    default => sub { Hash::Ordered->new },
);

has _status_to_ids => (
    is      => 'ro',
    default => sub { {} },
);

sub _add_job_status {
    my ($self, $id, $status) = @_;
    my $ids = $self->_status_to_ids->{$status} //= Hash::Ordered->new;
    $ids->push($id => 1);
    $self->_id_to_status->push($id => $status);
}

sub _remove_job_status {
    my ($self, $id) = @_;
    my $old = $self->_id_to_status->delete($id) or return;
    $self->_status_to_ids->{$old}->delete($id);
    return $old;
}

sub _update_status {
    my ($self, $status, $id) = @_;
    $self->_remove_job_status($id);
    $self->_add_job_status($id, $status);
}

sub queue_job  { shift->_update_status('queued',   @_) }
sub start_job  { shift->_update_status('started',  @_) }
sub finish_job { shift->_update_status('finished', @_) }
sub fail_job   { shift->_update_status('failed',   @_) }

sub get_status {
    my ($self, $id) = @_;
    return $self->_id_to_status->get($id);
}

sub _get_ids_for_status {
    my ($self, $status) = @_;
    my $ids = $self->_status_to_ids->{$status} or return;
    return $ids->keys;
}

sub registered { shift->_get_ids_for_status('registered') }
sub queued     { shift->_get_ids_for_status('queued')     }
sub started    { shift->_get_ids_for_status('started')    }
sub finished   { shift->_get_ids_for_status('finished')   }
sub failed     { shift->_get_ids_for_status('failed')     }

after add_job => sub {
    my ($self, $job) = @_;
    $self->_add_job_status($job->id, 'registered');
};

after remove_job => sub {
    my ($self, $id) = @_;
    $self->_remove_job_status($id);
};

1;
