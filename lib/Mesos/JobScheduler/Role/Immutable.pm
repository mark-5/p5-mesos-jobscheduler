package Mesos::JobScheduler::Role::Immutable;

use Moose::Role;
use namespace::autoclean;

has _build_args => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
);

around BUILDARGS => sub{
    my ($orig, $self) = @_;
    my $args = $self->$orig(@_[2 .. $#_]);
    $args->{_build_args} = { %$args };
    return $args;
};

sub update {
    my ($self, %args) = @_;
    my $class = ref $self;
    my $new   = $class->BUILDARGS(%args);
    my $old   = $self->_build_args;
    return $class->new(%$old, %$new);
}

1;
