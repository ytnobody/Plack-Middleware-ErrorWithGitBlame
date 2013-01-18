#line 1
use strict;

package Path::Class;
{
  $Path::Class::VERSION = '0.26';
}

{
  ## no critic
  no strict 'vars';
  @ISA = qw(Exporter);
  @EXPORT    = qw(file dir);
  @EXPORT_OK = qw(file dir foreign_file foreign_dir);
}

use Exporter;
use Path::Class::File;
use Path::Class::Dir;

sub file { Path::Class::File->new(@_) }
sub dir  { Path::Class::Dir ->new(@_) }
sub foreign_file { Path::Class::File->new_foreign(@_) }
sub foreign_dir  { Path::Class::Dir ->new_foreign(@_) }


1;
__END__

#line 188
