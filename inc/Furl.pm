#line 1
package Furl;
use strict;
use warnings;
use utf8;
use Furl::HTTP;
use Furl::Response;
use Carp ();
our $VERSION = '0.32';

use 5.008001;

sub new {
    my $class = shift;
    bless \(Furl::HTTP->new(header_format => Furl::HTTP::HEADERS_AS_HASHREF(), @_)), $class;
}

{
    no strict 'refs';
    for my $meth (qw/get head post delete put/) {
        *{__PACKAGE__ . '::' . $meth} = sub {
            my $self = shift;
            local $Carp::CarpLevel = $Carp::CarpLevel + 1;
            Furl::Response->new(${$self}->$meth(@_));
        }
    }
}

sub env_proxy {
    my $self = shift;
    $$self->env_proxy;
}

sub request {
    my $self = shift;

    my %args;
    if (@_ % 2 == 0) {
        %args = @_;
    } else {
        my $req = shift;
        %args = @_;
        my $req_headers= $req->headers;
        $req_headers->remove_header('Host'); # suppress duplicate Host header
        my $headers = +[
            map {
                my $k = $_;
                map { ( $k => $_ ) } $req_headers->header($_);
            } $req_headers->header_field_names
        ];

        $args{url}     = $req->uri;
        $args{method}  = $req->method;
        $args{content} = $req->content;
        $args{headers} = $headers;
    }
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    Furl::Response->new(${$self}->request(%args));
}

1;
__END__

=encoding utf8

#line 350
