#########################
## Copyright (C) 2002 Stathy G. Touloumis
## This is free software; you can redistribute it and/or modify it under
## the same terms as Perl itself.
##
use Test;
use strict;

use constant PATH_S=>		'/var/tmp/lib';
use constant PATH_A=>		[ qw(
	/var/tmp/lib
	/var/tmp/lib2
	/var/tmp/lib3 )
];
use constant DEBUG=>		0;

BEGIN { plan tests => 1 };

eval "use Class::Mixin";
if ( $@ ) {
	ok(0);
	warn $@, "\n\n";
} else {
	ok(1);
}
