use strict;
use Plack::App::File;
use Plack::Middleware::File::Sass;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

my $compass = `compass -v`;

SKIP: {
    skip "Compass is not installed.", 5 unless $compass;

    my $app = Plack::App::File->new(root => "t");
    $app = Plack::Middleware::File::Sass->wrap($app, compass => 1);

    test_psgi $app, sub {
        my $cb = shift;

        my $res = $cb->(GET "/");
        is $res->code, 404;

        $res = $cb->(GET "/compass.css");
        is $res->code, 200;
        is $res->content_type, 'text/css';
        like $res->content, qr/margin\s*:\s*0/;
        like $res->content, qr/padding\s*:\s*0/;
    };
}

done_testing;
