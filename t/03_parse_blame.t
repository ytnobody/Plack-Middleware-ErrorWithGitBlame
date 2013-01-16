use strict;
use warnings;
use Test::More;
use Furl;
use t::Util;

my $server = test_psgi_file( 't/data/git-repo/app_parse.psgi' );
my $client = Furl->new();
my $url = sprintf('http://127.0.0.1:%s', $server->port);
my $res = $client->get( $url );

is $res->code, '500';
like $res->content, qr/Illegal division by zero/;
like $res->content, qr/Commit: 49f9ddfc/;
like $res->content, qr/Committer: ytnobody/;
like $res->content, qr/Commited at: 2013-01-16 19:20:49 \+0900/;
like $res->content, qr/File: app_parse.psgi/;
like $res->content, qr/Line: 6/;

done_testing;
