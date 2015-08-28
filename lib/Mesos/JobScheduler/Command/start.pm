package Mesos::JobScheduler::Command::start;

use Mesos::JobScheduler;
use Proc::Daemon;
use Moose;
use namespace::autoclean;
extends 'MooseX::App::Cmd::Command';

# ABSTRACT: start an API server

has daemonize => (
    traits        => [qw(Getopt)],
    isa           => 'Bool',
    is            => 'ro',
    cmd_aliases   => 'd',
    default       => 0,
    documentation => 'run the server as a daemon',
);

has listen => (
    traits        => [qw(Getopt)],
    isa           => 'Str',
    is            => 'ro',
    cmd_aliases   => 'l',
    default       => '0.0.0.0:8080',
    documentation => 'the address to listen to http requests on',
);

has master => (
    traits => [qw(Getopt)],
    isa           => 'Str',
    is            => 'ro',
    cmd_aliases   => 'm',
    lazy          => 1,
    builder       => '_build_master',
    documentation => 'the mesos master to use',
);
sub _build_master {
    my ($self) = @_;
    return sprintf('zk://%s/mesos', $self->zk);
}

has pidfile => (
    traits => [qw(Getopt)],
    isa           => 'Str',
    is            => 'ro',
    cmd_aliases   => 'p',
    default       => '/var/run/mesos-jobscheduler.pid',
    documentation => 'the path to the pid file, if running with --daemonize',
);

has zk => (
    traits => [qw(Getopt)],
    isa           => 'Str',
    is            => 'ro',
    cmd_aliases   => 'z',
    required      => 1,
    documentation => 'the address of the zookeeper server to use',
);

sub execute {
    my ($self, $opt, $args) = @_;

    my $daemon = Proc::Daemon->new(pid_file => $self->pidfile);
    $daemon->Init if $self->daemonize;

    my ($host, $port) = split ':', $self->listen;
    my $config = {
        api => {
            http => {
                host => $host,
                port => $port,
            },
        },
        mesos => {
            master => $self->master,
        },
        zookeeper => {
            hosts => $self->zk,
        },
    };

    my $app = Mesos::JobScheduler->new(config => $config);
    my $api = $app->resolve('service' => 'api');

    $SIG{INT} = sub { exit 0 };
    $api->run;
}

__PACKAGE__->meta->make_immutable;
1;
