package Mesos::JobScheduler::Role::HasLogger::STDERR;

use Moo::Role;
use namespace::autoclean;
with 'Mesos::JobScheduler::Role::HasLogger';

after log_debug => sub {
    my ($self, $msg) = @_;
    print STDERR "> DEBUG | $msg\n";
};

after log_info => sub {
    my ($self, $msg) = @_;
    print STDERR "> INFO | $msg\n";
};

after log_error => sub {
    my ($self, $msg) = @_;
    print STDERR "> ERROR | $msg\n";
};

after log_fatal => sub {
    my ($self, $msg) = @_;
    print STDERR "> FATAL | $msg\n";
};

1;
