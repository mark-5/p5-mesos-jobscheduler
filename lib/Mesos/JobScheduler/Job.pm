package Mesos::JobScheduler::Job;

use Mesos::JobScheduler::Types qw(DateTime);
use Mesos::JobScheduler::Utils qw(now);
use Types::Standard qw(Dict Num Optional);
use Moose;
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

has command => (
    is       => 'ro',
    required => 1,
);

has created => (
    is      => 'ro',
    isa     => DateTime,
    coerce  => 1,
    default => sub { now() },
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
    default => 0,
);

has type => (
    is      => 'ro',
    builder => '_build_type',
);
sub _build_type {
    my ($self) = @_;
    (my $type = ref $self) =~ s/^Mesos::JobScheduler::Job(::)?//;
    return $type;
}

has updated => (
    is      => 'ro',
    isa     => DateTime,
    coerce  => 1,
    default => sub { now() },
);

around update => sub {
    my ($orig, $self, %args) = @_;
    return $self->$orig(
        created => $self->created,
        id      => $self->id,
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
    } qw(command created id name resources suspended type updated)};
    return $object;
}

__PACKAGE__->meta->make_immutable;
1;
