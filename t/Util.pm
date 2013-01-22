package t::Util;
use strict;
use warnings;
use Test::TCP;
use Path::Class;
use Cwd;
use Exporter 'import';
use Guard;

our @EXPORT = qw/ test_psgi_file /;

### Reason for not using Plack::Test
###  This test has to check that testee exists in git-repository.

sub test_psgi_file {
    my $file = file( shift );
    my $dir = $file->dir;
    my $pwd = getcwd;
    my $guard = guard { chdir $pwd };
    chdir $dir->stringify;
    my $server = Test::TCP->new(
        code => sub {
            my $port = shift;
            exec 'plackup', $file->basename, '-p' => $port;
        },
    );
    return $server;
}

1;
