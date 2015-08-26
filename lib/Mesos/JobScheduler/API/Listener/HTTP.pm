package Mesos::JobScheduler::API::Listener::HTTP;

use HTTP::Throwable::Factory qw(http_throw);
use Mesos::JobScheduler::Types qw(to_Job);
use Mesos::JobScheduler::Utils qw(decode_json encode_json);
use Plack::Request;
use Router::Simple;
use Safe::Isa qw($_DOES);
use Scalar::Util qw(weaken);
use Twiggy::Server;
use Moose::Role;
use namespace::autoclean;

has _psgi_app => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_psgi_app',
);
sub _build_psgi_app {
    weaken(my $self = shift);
    my $router = $self->_psgi_router;

    return sub {
        my $env = shift;
        my $req = Plack::Request->new($env);
        $self->_psgi_log_request($req);

        if (my $match  = $router->match($env)) {
            my $action = $match->{action};
            my $pretty = $req->query_parameters('pretty');

            return try {
                my $res = $self->$action($req, $match);
                return [
                    200,
                    ['Content-Type' => 'application/json'],
                    [encode_json($res, {pretty => $pretty})],
                ];
            } catch {
                $self->logger->error($_);
                return $_->as_psgi if $_->$_DOES('HTTP::Throwable');
                return [500, [], ['internal server error']];
            };
        } else {
            [404, [], ['not found']];
        }
    };
}

has _psgi_router => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_psgi_router',
);
sub _build_psgi_router {
    my ($self) = @_;
    my $router = Router::Simple->new;
    $router->connect(
        '/api/executions',
        {action => '_psgi_get_executions'},
        {method => 'GET'},
    );
    $router->connect(
        '/api/job',
        {action => '_psgi_add_job'},
        {method => 'POST'},
    );
    $router->connect(
        '/api/job/:id',
        {action => '_psgi_get_job'},
        {method => 'GET'},
    );
    $router->connect(
        '/api/job/:id',
        {action => '_psgi_update_job'},
        {method => 'PATCH'},
    );
    $router->connect(
        '/api/job/:id',
        {action => '_psgi_remove_job'},
        {method => 'DELETE'},
    );
    $router->connect(
        '/api/jobs',
        {action => '_psgi_get_jobs'},
        {method => 'GET'},
    );
    return $router;
}

has _psgi_server => (
    is      => 'ro',
    clearer => '_clear_psgi_server',
    writer  => '_set_psgi_server',
);

sub _psgi_log_request {
    my ($self, $req) = @_;
    my $method = $req->method;
    my $scheme = $req->scheme;
    my $uri    = $req->uri;
    my $proto  = $req->protocol;

    $self->logger->info("$method $scheme://$uri $proto");
}

sub _psgi_decode_body {
    my ($self, $req) = @_;
    my $raw = '';
    while (my $bytes = $req->body->read(my($buf), 2048)) {
        $raw .= $buf;
    }
    return decode_json($raw);
}

sub _psgi_get_executions {
    my ($self) = @_;
    return [$self->manager->all_executions];
}

sub _psgi_get_jobs {
    my ($self) = @_;
    return [$self->manager->all_jobs];
}

sub _psgi_get_job {
    my ($self, $req, $match) = @_;
    my $job = $self->manager->get_job($match->{id}) or http_throw('NotFound');

    return $job;
}

sub _psgi_add_job {
    my ($self, $req, $match) = @_;
    my $job = to_Job $self->_psgi_decode_body($req);

    $self->manager->add_job($job);
    return $job;
}

sub _psgi_update_job {
    my ($self, $req, $match) = @_;
    my $json = $self->_psgi_decode_body($req);

    my $job = $self->update_job($match->{id}, %$json) or http_throw('NotFound');
    return $job;
}

sub _psgi_remove_job {
    my ($self, $req, $match) = @_;
    my $old = $self->remove_job($match->{id}) or http_throw('NotFound');
    return $old;
}

after start_listeners => sub {
    my ($self) = @_;
    my $config = $self->config->{http} // {};

    my $host   = $config->{host} // '0.0.0.0';
    my $port   = $config->{port} // 8080;
    $self->logger->info("starting http listener on http://$host:$port");

    my $server = Twiggy::Server->new(%$config);
    $server->register_service($self->_psgi_app);
    $self->_set_psgi_server($server);
};

before stop_listeners => sub {
    my ($self) = @_;
    $self->logger->info('stopping http listener');
    $self->_clear_psgi_server;
};

1;
