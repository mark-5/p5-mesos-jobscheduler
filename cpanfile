requires 'namespace::autoclean', '0.16';
requires 'AnyEvent::Future';
requires 'Backbone::Events', '0.0.3';
requires 'Bread::Board';
requires 'Class::Method::Modifiers';
requires 'DateTime';
requires 'DateTime::Event::Cron';
requires 'DateTime::Format::RFC3339';
requires 'Exporter::Tiny';
requires 'FindBin::libs';
requires 'Getopt::Long::Descriptive';
requires 'Hash::Merge';
requires 'HTTP::Throwable';
requires 'JSON';
requires 'List::MoreUtils';
requires 'Mesos';
requires 'Module::Pluggable';
requires 'Module::Runtime';
requires 'Moose';
requires 'MooseX::App::Cmd';
requires 'MooseX::Traits::Pluggable';
requires 'Proc::Daemon';
requires 'Router::Simple';
requires 'Safe::Isa';
requires 'Scalar::Util';
requires 'Time::HiRes';
requires 'Twiggy';
requires 'Type::Tiny';
requires 'Types::UUID';
requires 'UUID::Tiny';
requires 'YAML';
requires 'ZooKeeper';

on develop => sub {
    requires 'Dist::Zilla::Plugin::ExtraTests';
    requires 'Dist::Zilla::Plugin::GitHub::Meta';
    requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
    requires 'Dist::Zilla::Plugin::ReadmeFromPod';
    requires 'Dist::Zilla::PluginBundle::Basic';
    requires 'Pod::Markdown';
    requires 'Test::Pod';
    requires 'Test::Strict';
};

on test => sub {
    requires 'Sub::Override';
    requires 'Test::Class::Moose', '0.55';
    requires 'Test::LeakTrace';
};
