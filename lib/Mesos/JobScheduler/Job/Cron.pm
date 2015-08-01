package Mesos::JobScheduler::Job::Cron;
use DateTime::Event::Cron;
use DateTime::Format::RFC3339;
use Mesos::JobScheduler::Utils qw(now);
use Types::DateTime qw(DateTimeUTC Format);
use Moo;
use namespace::autoclean;
extends 'Mesos::JobScheduler::Job';

=head1 ATTRIBUTES

=head2 crontab

=head2 scheduled

=head1 METHODS

=head2 next

=cut

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
    isa     => DateTimeUTC->plus_coercions(Format['RFC3339']),
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

around TO_JSON => sub {
    my ($orig, $self) = @_;
    my $object = $self->$orig;
    $object->{crontab} = $self->$crontab.'';
    $object->{scheduled} = DateTime::Format::RFC3339->format_datetime($self->scheduled);
    return $object;
};

1;
