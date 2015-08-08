package Mesos::JobScheduler::Types;

use strict;
use warnings;
use DateTime::Format::RFC3339;
use Mesos::JobScheduler::DateTime;
use Type::Library
    -base,
    -declare => qw(
        DateTime
    );
use Types::Standard qw(Num Str);
use Type::Utils -all;

class_type DateTime, {class => 'Mesos::JobScheduler::DateTime'};

coerce DateTime,
    from Str, <<'__END__';
do {
    my $obj = DateTime::Format::RFC3339->new->parse_datetime($_);
    Mesos::JobScheduler::DateTime->from_object(object => $obj);
}
__END__

1;
