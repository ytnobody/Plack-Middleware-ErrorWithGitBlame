use strict;
use warnings;
use Test::More;
use Furl;
use t::Util;

TODO: {
    local $TODO = 'Non-git repo test';
    my $server = test_psgi_file( 't/data/non-git/app.psgi' );
    my $client = Furl->new();
    my $url = sprintf('http://127.0.0.1:%s', $server->port);
    my $res = $client->get( $url );

    is $res->code, '500';
    like $res->content, qr/Illegal division by zero/;
    like $res->content, qr/\(not git repository\)/;
};

done_testing;
