package Mesos::JobScheduler::Role::Listener::HTTP;
use JSON qw(decode_json);
use Mesos::JobScheduler::Utils qw(psgi_json);
use Module::Runtime qw(require_module);
use Router::Simple;
use Scalar::Util qw(weaken);
use Twiggy::Server;
use Types::Standard qw(Dict Str Int);
use Moo::Role;
use namespace::autoclean;
with qw(
    Mesos::JobScheduler::Role::Interface::Logger
    Mesos::JobScheduler::Role::Listener
);

has http => (
    is       => 'ro',
    isa      => Dict[
        host => Str,
        port => Int,
    ],
    required => 1,
);

has _psgi_app => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_psgi_app',
);
sub _build_psgi_app {
    weaken(my $self = shift);
    my $router = $self->_psgi_router;
    return sub {
        my ($env) = @_;
        $self->log_info(
            join '',
            $env->{REQUEST_METHOD},
            ' ',
            $env->{'psgi.url_scheme'}.'://',
            $env->{'HTTP_HOST'},
            $env->{'SCRIPT_NAME'},
            $env->{'PATH_INFO'},
            ' ',
            $env->{SERVER_PROTOCOL},
        );
        if (my $match  = $router->match($env)) {
            my $action = $match->{action};
            $self->$action($env, $match);
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

sub _psgi_decode_body {
    my ($self, $env) = @_;
    my $raw = '';
    while (my $bytes = $env->{'psgi.input'}->read(my($buf), 2048)) {
        $raw .= $buf;
    }
    return decode_json($raw);
}

sub _json_to_job {
    my ($self, $json) = @_;
    $json = {%$json};
    my $class = join '::', 'Mesos::JobScheduler::Job', delete $json->{type};
    require_module($class);
    return $class->new(%$json);
}

sub _psgi_get_job {
    my ($self, $env, $match) = @_;
    my $job = $self->get_job($match->{id});
    return $job ? psgi_json($job) : psgi_json({}, 404);
}

sub _psgi_add_job {
    my ($self, $env, $match) = @_;
    my $json = $self->_psgi_decode_body($env);
    my $job  = $self->_json_to_job($json);

    $self->add_job($job);
    return psgi_json($job);
}

sub _psgi_update_job {
    my ($self, $env, $match) = @_;
    my $json = $self->_psgi_decode_body($env);

    my $job  = $self->update_job($match->{id}, %$json);
    return psgi_json($job);
}

sub _psgi_remove_job {
    my ($self, $env, $match) = @_;
    my $old = $self->remove_job($match->{id});
    return psgi_json($old);
}


after start_listener => sub {
    my ($self) = @_;
    my $http   = $self->http;
    $self->log_info(
        "starting http listener on http://$http->{host}:$http->{port}"
    );

    my $server = Twiggy::Server->new(%$http);
    $server->register_service($self->_psgi_app);
    $self->_set_psgi_server($server);
};

after stop_listener => sub {
    my ($self) = @_;
    $self->log_info('stopping http listener');
    $self->_clear_psgi_server;
};

1;
