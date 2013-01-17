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

and plackup it. Then, an error as following will raise when app gets request.

  Illegal division by zero
  Commit: 49f9ddfc
  Committer: ytnobody
  Commited at: 2013-01-16 19:20:49 +0900
  File: app_parse.psgi
  Line: 5
   at /home/ytnobody/work/Plack-Middleware-ErrorWithGitBlame/blib/lib/Plack/Middleware/ErrorWithGitBlame.pm line 50
  	Plack::Middleware::ErrorWithGitBlame::call('Plack::Middleware::ErrorWithGitBlame=HASH(0x19288d18)', 'HASH(0x19254158)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Component.pm line 39
  	Plack::Component::__ANON__('HASH(0x19254158)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Middleware/Lint.pm line 24
  	Plack::Middleware::Lint::call('Plack::Middleware::Lint=HASH(0x18e0e320)', 'HASH(0x19254158)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Component.pm line 39
  	Plack::Middleware::StackTrace::__ANON__ at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Try/Tiny.pm line 71
  	eval {...} at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Try/Tiny.pm line 67
  	Plack::Middleware::StackTrace::call('Plack::Middleware::StackTrace=HASH(0x18e0e860)', 'HASH(0x19254158)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Component.pm line 39
  	Plack::Component::__ANON__('HASH(0x19254158)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Middleware/AccessLog.pm line 28
  	Plack::Middleware::AccessLog::call('Plack::Middleware::AccessLog=HASH(0x18e0e620)', 'HASH(0x19254158)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Component.pm line 39
  	Plack::Component::__ANON__('HASH(0x19254158)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Middleware/ContentLength.pm line 10
  	Plack::Middleware::ContentLength::call('Plack::Middleware::ContentLength=HASH(0x1924ff90)', 'HASH(0x19254158)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Component.pm line 39
  	Plack::Component::__ANON__('HASH(0x19254158)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Util.pm line 142
  	eval {...} at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Util.pm line 142
  	Plack::Util::run_app('CODE(0x19289018)', 'HASH(0x19254158)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/HTTP/Server/PSGI.pm line 169
  	HTTP::Server::PSGI::handle_connection('HTTP::Server::PSGI=HASH(0x19288f10)', 'HASH(0x19254158)', 'IO::Socket::INET=GLOB(0x19289558)', 'CODE(0x19289018)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/HTTP/Server/PSGI.pm line 128
  	HTTP::Server::PSGI::accept_loop('HTTP::Server::PSGI=HASH(0x19288f10)', 'CODE(0x18e0e4e8)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/HTTP/Server/PSGI.pm line 55
  	HTTP::Server::PSGI::run('HTTP::Server::PSGI=HASH(0x19288f10)', 'CODE(0x18e0e4e8)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Handler/HTTP/Server/PSGI.pm line 14
  	Plack::Handler::HTTP::Server::PSGI::run('Plack::Handler::Standalone=HASH(0x18d66148)', 'CODE(0x18e0e4e8)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Loader.pm line 84
  	Plack::Loader::run('Plack::Loader=HASH(0x18c78470)', 'Plack::Handler::Standalone=HASH(0x18d66148)') called at /home/ytnobody/perl5/perlbrew/perls/perl-5.12.3/lib/site_perl/5.12.3/Plack/Runner.pm line 267
  	Plack::Runner::run('Plack::Runner=HASH(0x18a8ba60)') called at /home/ytnobody/perl5/perlbrew/perls/current/bin/plackup line 10


=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
