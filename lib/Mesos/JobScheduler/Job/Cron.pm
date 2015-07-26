package Mesos::JobScheduler::Job::Cron;
use DateTime::Event::Cron;
use Mesos::JobScheduler::Utils qw(now);
use Moo;
use namespace::autoclean;
extends 'Mesos::JobScheduler::Job';

has crontab => (
    is       => 'ro',
    required => 1,
);

has _crontab_obj => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_crontab_obj',
);
sub _build_crontab_obj {
    my ($self)  = @_;
    return DateTime::Event::Cron->new_from_cron($self->crontab);
}

has scheduled => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_scheduled',
);
sub _build_scheduled {
    my ($self) = @_;
    my $now = now();

    return $now if $self->_crontab_obj->match($now);
    return $self->next($now);
}

sub next {
    my ($self, $from) = @_;
    return $self->_crontab_obj->next($from // now());
}

1;
