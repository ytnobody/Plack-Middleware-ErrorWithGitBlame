use strict;
use warnings;
use Test::More;
use Furl;
use t::Util;

my $server = test_psgi_file( 't/data/git-repo/app.psgi' );
my $client = Furl->new();
my $url = sprintf('http://127.0.0.1:%s', $server->port);
my $res = $client->get( $url );

is $res->code, '500';
like $res->content, qr/Illegal division by zero/;
like $res->content, qr/f7507b91/;
like $res->content, qr/ytnobody/;
like $res->content, qr/2013-01-16 18:32:55 \+0900/;
like $res->content, qr/ 6\) /;

done_testing;
