package Mesos::JobScheduler::XUnit::Role::JobCreator;
use Mesos::JobScheduler::Job;
use Module::Runtime qw(require_module);
use Test::Class::Moose::Role;
use namespace::autoclean;

sub new_job {
    my ($test, @args) = @_;
    my $class = 'Mesos::JobScheduler::Job';
    if (@args % 2) {
        $class = join '::', $class, shift @args;
        require_module($class);
    }
    return $class->new(
        command => "test_command_" . rand,
        name    => "test_name_"    . rand,
        @args,
    );
}

1;
