use strict;
use warnings;
use Plack::Builder;

my $app = sub {
    my $x = 2 / 0; ### XXX error!
    [ '200', [], [$x] ];
};

builder {
    enable "ErrorWithGitBlame", parse_blame => 1;
    $app;
};
