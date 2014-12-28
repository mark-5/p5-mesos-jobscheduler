package Mesos::Framework::JobScheduler::Role::Job::HasCrontab;
use DateTime::Event::Cron;
use Types::Standard qw(Str);
use Type::Utils qw(class_type);
use Moo::Role;
with "Mesos::Framework::JobScheduler::Role::Job::HasTimer";


sub _build_scheduled_time { shift->next_time }

has crontab => (
    is       => "ro",
    isa      => class_type({class => "DateTime::Event::Cron"})->plus_coercions(
        Str, sub { DateTime::Event::Cron->new_from_cron(shift) }
    ),
    coerce   => 1,
    required => 1,
);


sub next_time {
    my ($self, $now) = @_;
    return $self->crontab->next($now || $self->now);
}

sub executions {
    my ($self, %args) = @_;
    my ($from, $until) = @args{qw(from until)};
    my @executions;
    my $next = $self->next_time($from || $self->now);
    while ($next <= $until) {
        push @executions, $next;
        $next = $self->next_time($next);
    }
    return @executions;
}


1;
