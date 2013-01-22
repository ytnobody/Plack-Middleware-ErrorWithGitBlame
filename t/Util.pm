package t::Util;
use strict;
use warnings;
use Test::TCP;
use Path::Class;
use Cwd;
use Guard;
use File::Temp 'tempdir';
use File::Copy::Recursive 'dircopy';
use Exporter 'import';

our @EXPORT = qw/ test_psgi_file /;

### Reason for not using Plack::Test
###  This test has to check that testee exists in git-repository.

sub test_psgi_file {
    my $file = file( shift );
    my $dir = $file->dir;
    my $tmpdir = copy_temporary( $dir->stringify );
    my $pwd = getcwd;
    my $guard = guard { chdir $pwd };
    chdir $tmpdir;
    my $server = Test::TCP->new(
        code => sub {
            my $port = shift;
            exec 'plackup', $file->basename, '-p' => $port;
        },
    );
    return $server;
}

sub copy_temporary {
    my $dir = shift;
    my $tmpdir = tempdir( dir => 't/workspace', CLEANUP => 1 );
    dircopy( $dir, $tmpdir );
    return $tmpdir;
}

1;
