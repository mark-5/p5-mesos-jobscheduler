package Mesos::JobScheduler::Job;

use Mesos::JobScheduler::Types qw(DateTime);
use Mesos::JobScheduler::Utils qw(now);
use Module::Runtime qw(require_module);
use Types::Standard qw(Dict Num Optional);
use Types::UUID qw(Uuid);
use Moo;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::HasId
    Mesos::JobScheduler::Role::Immutable
);

# ABSTRACT: a base class for Mesos::JobScheduler jobs

=head1 ATTRIBUTES

=head2 command

=head2 name

=head2 resources

=head2 suspended

=head1 METHODS

=head2 update

=cut

has added => (
    is      => 'ro',
    isa     => DateTime,
    coerce  => 1,
    default => sub { now() },
);

has command => (
    is       => 'ro',
    required => 1,
);

has name => (
    is       => 'ro',
    required => 1,
);

has resources => (
    is  => 'ro',
    isa => Dict[
        mem  => Optional[Num],
        cpus => Optional[Num],
        disk => Optional[Num],
    ],
    writer  => '_set_resources',
    default => sub { {} },
);

has suspended => (
    is      => 'ro',
    default => sub { 0 },
);

has updated => (
    is      => 'ro',
    isa     => DateTime,
    coerce  => 1,
    default => sub { now() },
);

around update => sub {
    my ($orig, $self, %args) = @_;
    return $self->$orig(
        added => $self->added,
        id    => $self->id,
        %args,
    );
};

sub BUILD {
    my ($self)   = @_;
    my %defaults = (mem => 128, cpus => 0.1, disk => 256);
    $self->_set_resources({%defaults, %{$self->resources}});
}

sub TO_JSON {
    my ($self) = @_;
    my $object = {map {
        ($_, $self->$_)
    } qw(command id name resources suspended)};
    ($object->{type} = ref $self) =~ s/^Mesos::JobScheduler::Job:://;
    return $object;
}

around new => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my %args = @_ == 1 ? %{$_[0]} : @_;
    if (my $type = delete $args{type}) {
        my $class = "Mesos::JobScheduler::Job::$type";
        require_module($class);
        return $class->new(%args);
    } else {
        return $self->$orig(@_);
    }
};

1;
