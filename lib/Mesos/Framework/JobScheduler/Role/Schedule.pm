package Mesos::Framework::JobScheduler::Role::Schedule;
use Carp;
use Moo::Role;

=head1 NAME

Mesos::Framework::JobScheduler::Role::Schedule

=head1 METHODS

=head2 all()

=head2 get($job_name)

=head2 update($job_name, $job)

=head2 register($job)

=head2 deregister($job_name)

=cut

requires qw(
    all
    get
    update
    register
    deregister
);

before register => sub {
    my ($self, $job) = @_;
    my $name = $job->name;
    croak "$name is already registered" if $self->get($name);
};

after register => sub {
    my ($self, $job) = @_;
    $job->status("registered");
};

before deregister => sub {
    my ($self, $name) = @_;
    my $job = $self->get($name) or return;
    $job->status("deregistered");
};


1;
