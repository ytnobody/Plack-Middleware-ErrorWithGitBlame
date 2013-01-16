package Plack::Middleware::ErrorWithGitBlame;
use strict;
use warnings;
use parent 'Plack::Middleware';
our $VERSION = '0.01';

use Git::Class;
use Cwd;
use Carp;

our $PARSE_BLAME = 0;
our $TREE;

sub _blame {
    my ($filename, $line) = @_;
    my ($result) = eval { $TREE->git('blame', $filename, '-L', $line) };
    return $result unless $@;
}

sub _parse_blame {
    my $blame = shift;
    my %res = ();
    @res{'hash','committer','datetime','line','source'} = $blame =~ /^([0-9A-Fa-f]+?) \((.+?) ([0-9]{4}\-[0-9]{2}\-[0-9]{2} [0-9]{2}\:[0-9]{2}\:[0-9]{2} [\-\+][0-9]{4}) +([0-9]+)\)(.+)$/;
    return \%res;
}

sub _parse_error {
    my $error = shift;
    my %res = ();
    @res{'message','file','line'} = $error =~ /^(.+) at (.+) line ([0-9]+)\.$/;
    return \%res;
}

sub prepare_app {
    my $self = shift;
    $TREE = Git::Class::Worktree->new(path => getcwd);
    $PARSE_BLAME = $self->{parse_blame} ? 1 : 0;
}

sub call {
    my ($self, $env) = @_;
    my $res = eval{ $self->app->($env) };
    if ( $@ ) {
        my $errstr = $@;
        my $error = _parse_error($errstr);
        my $blame = _blame($error->{file}, $error->{line});
        if ( $blame ) {
            if ( $PARSE_BLAME ) {
                my $commit = _parse_blame($blame);
                die sprintf(
                    "%s\nCommit: %s\nCommitter: %s\nCommited at: %s\nFile: %s\nLine: %s\n", 
                    $error->{message}, $commit->{hash}, $commit->{committer}, $commit->{datetime}, $error->{file}, $error->{line}
                );
            }
            else {
                die sprintf('%s [git-blame] %s', $error->{message}, $blame);
            }
        }
        else {
            die "$errstr (not git repository)";
        }
    }
    return $res;
};

1;
__END__

=head1 NAME

Plack::Middleware::ErrorWithGitBlame - error with git-blame

=head1 SYNOPSIS

in your psgi file,

  use Plack::Builder;
  
  ### your app
  my $app = sub { 
      my $x = 2 / 0 # error!
      [200, [], ['x is '.$x]]; 
  };
  
  builder {
      enable 'ErrorWithGitBlame', parse_blame => 1;
      $app;
  };

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
