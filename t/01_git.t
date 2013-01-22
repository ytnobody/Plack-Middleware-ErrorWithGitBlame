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
like $res->content, qr/55c19289/;
like $res->content, qr/ytnobody/;
like $res->content, qr/2013-01-22 14:48:48 \+0900/;
like $res->content, qr/ 6\) /;

done_testing;
