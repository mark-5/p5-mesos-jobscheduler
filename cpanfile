requires 'namespace::autoclean', '0.16';
requires 'AnyEvent::Future';
requires 'DateTime::Event::Cron';
requires 'Exporter::Tiny';
requires 'Hash::Ordered';
requires 'Mesos';
requires 'Moo', '0.091008';
requires 'MooX::Rebuild';
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
    requires 'Test::Class::Moose', '0.55';
};
