use strict;
use warnings;
use Plack::Builder;

my $app = sub {
    my $x = 0 / 2; ### XXX error!
    [ '200', [], [$x] ];
};

builder {
    enable "ErrorWithGitBlame";
    $app;
};
