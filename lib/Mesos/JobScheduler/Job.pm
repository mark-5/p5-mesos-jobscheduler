package Mesos::JobScheduler::Job;

use Types::Standard qw(Dict Num Optional);
use Types::UUID qw(Uuid);
use Moo;
use namespace::autoclean;
with qw(
    MooX::Rebuild
    Mesos::JobScheduler::Role::HasId
);

# ABSTRACT: a base class for Mesos::JobScheduler jobs

=head1 ATTRIBUTES

=head2 command

=head2 name

=head2 resources

=head1 METHODS

=head2 update

=cut

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

sub update {
    my ($self, %args) = @_;
    # don't generate a new id
    return $self->rebuild(id => $self->id, %args);
}

sub BUILD {
    my ($self)   = @_;
    my %defaults = (mem => 128, cpus => 0.1, disk => 256);
    $self->_set_resources({%defaults, %{$self->resources}});
}

sub TO_JSON {
    my ($self) = @_;
    my $object = {map {
        ($_, $self->$_)
    } qw(command id name resources)};
    ($object->{type} = ref $self) =~ s/^Mesos::JobScheduler::Job:://;
    return $object;
}

1;
