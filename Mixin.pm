=pod

=head1 NAME

Class::Mixin - API for aliasing methods to/from other classes

=head1 DEPENDENCIES

=over 4

=item *

Symbol

=back

=head1 INSTALLATION

To install this module type the following:

=over 2

=item *

perl Makefile.PL

=item *

make

=item *

make test

=item *

make install

=back

=head1 OVERVIEW

Blah

=head1 SYNOPSIS

 package Company::Subsystem::Enrollment::User::Student;
 use Company::User ();

 use Class::Mixin to=> 'Foo::Bar';

=head1 CONSTANTS

=head1 METHODS

=cut
#######################################################
package Class::Mixin;
use strict;

use Symbol ();
use warnings::register;

our $VERSION = '0.01';

my %r = map { $_=> 1 } qw(
	BEGIN
	INIT
	CHECK
	END
	DESTROY
	AUTOLOAD
	
	import
	can
	isa
	ISA
	STDIN
	STDOUT
	STDERR
	ARGV
	ARGVOUT
	ENV
	INC
	SIG
);

sub __new {
	return $Class::Mixin::OBJ if defined $Class::Mixin::OBJ;
	$Class::Mixin::OBJ = bless {}, shift;
	return $Class::Mixin::OBJ;
}

=pod

=head2 import

Method used when loading class to import symbols or perform
some function.  In this case we take the calling classes methods
and map them into the class passed in as a parameter.

=over 2

=item Input

=over 2

=item None

=back

=item Output

=over 2

=item *

Apache Request Object

=back

=back

=cut
sub import {
	my $cl = shift;
	return unless @_;
	my $obj = $Class::Mixin::OBJ;

	my $d = shift || 'error';
	if ( $d !~ /^(?:from|to)$/oi ) {
		require Carp;
		Carp::croak <<E;
Mixin requires first parameter to be either
1) from : mixin methods FROM specified class to calling class
2) to : mixin method TO specified class from calling class
E
	}

    my $class1 = shift || do {
		require Carp;
		Carp::croak <<E;
Mixin requires second parameter to be class to mixin
from or to.
E
		
	};
    my $class2 = caller;
	my $key = join( '|', $d, $class1, $class2 );
	return if exists $obj->{ $key };
	$obj->{ $key } = {};

}

CHECK { resync() }

=pod

=head2 B<Desctructor> DESTROY

This modules uses a destructor for un-mixing methods.  This is done in
the case that this module is unloaded for some reason.  It will return
modules to their original states.

=over 2

=item Input

=over 2

=item *

Class::Mixin object

=back

=item Output

=over 2

=item None

=back

=back

=cut
sub DESTROY {
	my $obj = shift;

	while ( my($k, $v) = each %$obj ) {
		my $d = ( split /\|/ )[0];
		return if $d =~ /^(?:from)$/io;

		my $m = $v->{'method'};
		my $c = $v->{'class'} . '::';
		my $s = $v->{'symbol_ref'};

		*{ $s } = undef;
		{
			no strict 'refs';
			delete ${ $c }{ $m };
		}
		$s = undef;
	}
}

=pod

=head2 resync

Function used to process registered 'mixins'.  Typically automatically
called once immediately after program compilation.  Sometimes though you
may want to call it manually if a modules is reloaded.

=over 2

=item Input

=over 2

=item None

=back

=item Output

=over 2

=item None

=back

=back

=cut
sub resync {
	my $obj = $Class::Mixin::OBJ;

	foreach my $key ( keys %$obj ) {
		my ($d, $class1, $class2) = split /\|/, $key;

		my $mixin = ( $d eq 'from' ? $class1 : $class2 );
		my $target = ( $d eq 'from' ? $class2 : $class1 );
		my $mixinSym = $mixin . '::';

		{
			no strict 'refs';

			foreach my $method ( keys %$mixinSym ) {
				if ( exists $r{ $method } ) {
					warnings::warn <<W if warnings::enabled();
Unable to Mixin method '$method', restricted
W

				} elsif ( $target->can( $method ) and !exists $obj->{$method} ) {
		 			require Carp;
					Carp::croak <<E;
Unable to Mixin method '$method'
FROM $mixin
TO $target
already defined in $target
E
				} else {
					my $m = Symbol::qualify_to_ref( $method, $mixin );
					my $t = Symbol::qualify_to_ref( $method, $target );
					*{ $t } = *{ $m };

					$obj->{ $key } = {
						class=>		$target,
						method=>	$method,
						symbol=>	$t,
					};

				}

			}

		}

	}

}

1;

__END__

=pod

=head1 HISTORY

=over 2

=item *

2003/06/12 Created

=back

=head1 AUTHOR

=over 2

=item *

Stathy G. Touloumis <stathy-classmixin@stathy.com>

=back

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2003 Stathy G. Touloumis

This is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

