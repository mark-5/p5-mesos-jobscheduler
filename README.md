# NAME

Mesos::JobScheduler - services for building Mesos job scheduling frameworks

# VERSION

version 0.0.1

# SYNOPSIS

    my $app = Mesos::JobScheduler->new(
        config => {
            mesos     => { master => 'zk://localhost:2181/mesos' },
            zookeeper => { hosts  => 'localhost:2181'            },
        },
    );
    my $api = $app->resolve('service' => 'api');
    $api->run;

# DESCRIPTION

Mesos::JobScheduler is a Bread::Board container, wired with a variety of services intended for Mesos job scheduling frameworks.

# SERVICES

## api

## config

## event\_loop

## framework

## logger

## manager

## mesos

## storage

## zookeeper

# EXTENDING

    package MyScheduler;
    use Bread::Board;
    use Moose;
    extends 'Mesos::JobScheduler';

    sub BUILD {
        my ($self) = @_;
        container $self => as {
            service '+framework' => (
                class => 'MyScheduler::Framework',
            );
        };
    }

# AUTHOR

Mark Flickinger

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Mark Flickinger.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
