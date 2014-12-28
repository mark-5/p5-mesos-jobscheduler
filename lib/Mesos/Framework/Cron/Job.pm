package Mesos::Framework::Cron::Job;
use AnyEvent::Timer::Cron;
use Moo;
with 'Mesos::Framework::Role::Job';

has crontab => (is => 'rw');


1;
