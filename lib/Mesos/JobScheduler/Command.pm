package Mesos::JobScheduler::Command;

use Moose;
extends 'MooseX::App::Cmd';

use constant plugin_search_path => __PACKAGE__;

__PACKAGE__->meta->make_immutable;
1;
