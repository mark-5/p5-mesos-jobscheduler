requires 'namespace::autoclean', '0.16';
requires 'Bread::Board';
requires 'Class::Method::Modifiers';
requires 'DateTime';
requires 'DateTime::Format::RFC3339';
requires 'Exporter::Tiny';
requires 'Hash::Merge';
requires 'JSON';
requires 'Mesos';
requires 'Module::Runtime';
requires 'Moose';
requires 'Scalar::Util';
requires 'Time::HiRes';
requires 'Type::Tiny';
requires 'Types::UUID';
requires 'UUID::Tiny';
requires 'YAML';

on develop => sub {
    requires 'Dist::Zilla::Plugin::ExtraTests';
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
