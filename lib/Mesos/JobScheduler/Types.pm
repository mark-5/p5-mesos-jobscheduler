package Mesos::JobScheduler::Types;

use strict;
use warnings;
use DateTime::Format::RFC3339;
use Mesos::JobScheduler::DateTime;
use Type::Library
    -base,
    -declare => qw(
        DateTime
        Execution
        Job
    );
use Types::Standard qw(HashRef InstanceOf Num Str);
use Type::Utils -all;

class_type DateTime, {class => 'Mesos::JobScheduler::DateTime'};

coerce DateTime,
    from Str, <<'__END__';
do {
    my $obj = DateTime::Format::RFC3339->new->parse_datetime($_);
    Mesos::JobScheduler::DateTime->from_object(object => $obj);
}
__END__

class_type Execution, {class => 'Mesos::JobScheduler::Execution'};

coerce Execution, from HashRef, 'Mesos::JobScheduler::Execution->new($_)';

class_type Job, {class => 'Mesos::JobScheduler::Job'};

coerce Job, from HashRef, 'Mesos::JobScheduler::Job->new(%$_)';


require Mesos::JobScheduler::Execution;
require Mesos::JobScheduler::Job;

1;
