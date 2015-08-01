package Mesos::JobScheduler::Role::HasLogger::STDERR;

use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::HasLogger';

after log_debug => sub {
    my ($self, $msg) = @_;
    warn "> DEBUG | $msg\n";
};

after log_info => sub {
    my ($self, $msg) = @_;
    warn "> INFO | $msg\n";
};

after log_error => sub {
    my ($self, $msg) = @_;
    warn "> ERROR | $msg\n";
};

after log_fatal => sub {
    my ($self, $msg) = @_;
    warn "> FATAL | $msg\n";
};

1;
