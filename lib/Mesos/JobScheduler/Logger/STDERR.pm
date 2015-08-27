package Mesos::JobScheduler::Logger;

use Mesos::JobScheduler::Types qw(Config);
use Moose;
use namespace::autoclean;
extends 'Mesos::JobScheduler::Logger';

sub debug {
    my ($self, $msg) = @_;
    print STDERR sprintf("> DEBUG | %s\n", $msg//'');
}

sub info {
    my ($self, $msg) = @_;
    print STDERR sprintf("> INFO | %s\n", $msg//'');

}

sub error {
    my ($self, $msg) = @_;
    print STDERR sprintf("> ERROR | %s\n", $msg//'');
}

sub fatal {
    my ($self, $msg) = @_;
    print STDERR sprintf("> FATAL | %s\n", $msg//'');
}

__PACKAGE__->meta->make_immutable;
1;
