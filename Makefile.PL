#########################
## Copyright (C) 2002 Stathy G. Touloumis
## This is free software; you can redistribute it and/or modify it under
## the same terms as Perl itself.
##
package Class::Mixin;
use strict;

use ExtUtils::MakeMaker;

WriteMakefile(

    NAME=>					__PACKAGE__,
	'PREREQ_PM'=>			{ Symbol=> 1.02 },
    VERSION_FROM=>			'Mixin.pm',
	($] >= 5.005 ?
		(
			ABSTRACT_FROM =>		'Mixin.pm',
			AUTHOR=>				'Stathy G. Touloumis <stathy-classmixin@stathy.com>'
		) :
		()
	),
    dist=>					{
		COMPRESS=>			'gzip',
		SUFFIX=>			'gz',
    },

);

__END__

