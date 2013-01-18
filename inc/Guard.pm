#line 1
#line 40

package Guard;

no warnings;

BEGIN {
   $VERSION = '1.022';
   @ISA = qw(Exporter);
   @EXPORT = qw(guard scope_guard);

   require Exporter;

   require XSLoader;
   XSLoader::load Guard, $VERSION;
}

our $DIED = sub { warn "$@" };

#line 157

1;

#line 212

