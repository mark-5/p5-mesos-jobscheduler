package Mesos::JobScheduler::Logger;

use Mesos::JobScheduler::Types qw(Config);
use Moose;
use namespace::autoclean;

has config => (
    is      => 'ro',
    isa     => Config['logger'],
    coerce  => 1,
    default => sub { {} },
);

sub debug { }
sub info  { }
sub error { }
sub fatal { }

__PACKAGE__->meta->make_immutable;
1;
