package Mesos::JobScheduler::Types;

use strict;
use warnings;
use DateTime::Format::RFC3339;
use Mesos::JobScheduler::DateTime;
use Module::Runtime qw(require_module);
use Type::Coercion;
use Type::Library
    -base,
    -declare => qw(Config ConfigField DateTime Execution Job);
use Type::Utils -all;
use Types::Standard qw(HashRef InstanceOf Str);

my $config_class = 'Mesos::JobScheduler::Config';
declare Config,
    as InstanceOf[$config_class],
    constraint_generator => sub { ConfigField[@_] };

coerce Config,
    from HashRef, <<'__END__';
do {
    require Mesos::JobScheduler::Config;
    Mesos::JobScheduler::Config->new($_);
}
__END__

declare ConfigField,
    as ~Config,
    name_generator => sub {
        my ($type, $field) = @_;
        return "Config[$field]";
    },
    constraint_generator => sub {
        require_module($config_class);
        my ($field) = @_;
        my $attr    = $config_class->meta->find_attribute_by_name($field)
            or die "No $field field could be found for Mesos::JobScheduler::Config";
        my $tc = $attr->type_constraint;
        return $tc && $tc->constraint;
    },
    coercion_generator => sub {
        require_module($config_class);
        my ($parent, $child, $field) = @_;
        my $attr = $config_class->meta->find_attribute_by_name($field)
            or die "No $field field could be found for Mesos::JobScheduler::Config";
        my $from_config = coerce ConfigField,
            from Config,
            "\$_->$field";
        my $tc       = $attr->type_constraint;
        my $coercion = $tc && $tc->coercion;

        return $from_config unless $coercion;
        return Type::Coercion->add($from_config, $coercion)->freeze;
    };

class_type DateTime, {class => 'Mesos::JobScheduler::DateTime'};

coerce DateTime,
    from Str, <<'__END__';
do {
    my $obj = DateTime::Format::RFC3339->new->parse_datetime($_);
    Mesos::JobScheduler::DateTime->from_object(object => $obj);
}
__END__

declare Execution, as InstanceOf['Mesos::JobScheduler::Execution'];

coerce Execution,
    from HashRef, <<'__END__';
do {
    my $args  = {%{$_}};
    my $class = 'Mesos::JobScheduler::Execution';
    if (my $type = delete $args->{type}) {
        $class = "${class}::$type";
    }
    Module::Runtime::require_module($class);
    $class->new(%$args);
}
__END__

declare Job, as InstanceOf['Mesos::JobScheduler::Job'];

coerce Job,
    from HashRef, <<'__END__';
do {
    my $args  = {%{$_}};
    my $class = 'Mesos::JobScheduler::Job';
    if (my $type = delete $args->{type}) {
        $class = "${class}::$type";
    }
    Module::Runtime::require_module($class);
    $class->new(%$args);
}
__END__

1;
