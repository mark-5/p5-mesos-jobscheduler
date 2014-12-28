package Mesos::Framework::XUnit::Utils;
use Mesos::Messages;
use parent "Exporter";

our @EXPORT = qw(executor ae_sleep);
our @EXPORT_OK = @EXPORT;

sub executor {
    return Mesos::ExecutorInfo->new({
        executor_id => "test",
        command     => "/bin/echo a test",
    });
}

sub ae_sleep {
    my ($timeout) = @_;
    return unless $timeout;
    my $cv = AnyEvent->condvar;
    my $w = AnyEvent->timer(after => $timeout, cb => sub { $cv->send });
    $cv->recv;
}

1;
