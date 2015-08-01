package Mesos::JobScheduler::Role::HasLogger;

use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::Interface::Logger';

sub log {
    my ($self, $level, $msg) = @_;
    my $logger = $self->can("log_$level");
    return $self->$logger($msg);
}

sub log_debug { }

sub log_info { }

sub log_error { }

sub log_fatal { }

1;
