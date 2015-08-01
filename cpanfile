requires 'namespace::autoclean', '0.16';
requires 'AnyEvent::Future';
requires 'DateTime::Event::Cron';
requires 'DateTime::Format::RFC3339';
requires 'Exporter::Tiny';
requires 'Getopt::Long::Descriptive';
requires 'Hash::Ordered';
requires 'JSON';
requires 'List::MoreUtils';
requires 'Mesos';
requires 'Moo', '0.091008';
requires 'MooX::Rebuild';
requires 'Plack::Request';
requires 'Router::Simple';
requires 'Twiggy::Server';
requires 'Types::DateTime';
requires 'Types::UUID';

on develop => sub {
    requires 'Dist::Zilla::Plugin::ExtraTests';
    requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
    requires 'Dist::Zilla::Plugin::ReadmeFromPod';
    requires 'Dist::Zilla::PluginBundle::Basic';
    requires 'Pod::Markdown';
};

on test => sub {
    requires 'Module::Runtime';
    requires 'Sub::Override';
    requires 'Test::Class::Moose', '0.55';
};
