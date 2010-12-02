#######################################################################
# $Id: Makefile.PL,v 1.12 2010-12-02 03:34:11 dpchrist Exp $
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
# USA.
#######################################################################

package Dpchrist::ExtUtils::MakeMaker;	# for symbols

use ExtUtils::MakeMaker;

eval "use Test::Manifest";
warn $@ if $@;

### Uncomment the following to verify daisy-chaining of MY::postamble
### overrides by Dpchrist::ExtUtils::MakeMaker:
#sub MY::postamble
#{
#    my ($o) = @_;
#    return join(' ', '#', __FILE__, __LINE__, scalar localtime, "\n");
#}

eval {
    require Dpchrist::ExtUtils::MakeMaker;
    import  Dpchrist::ExtUtils::MakeMaker (
	postamble => sub {
	    my ($o, $prev) = @_;
	    return join('',
		$prev,
		mcpani  ($o, $ENV{CPAN_AUTHORID}),
		pod2html($o, 'lib/Dpchrist/ExtUtils/MakeMaker.pm'),
		readme  ($o, 'lib/Dpchrist/ExtUtils/MakeMaker.pm'),
		release ($o, $ENV{RELEASE_ROOT}),
	    );
	},
    );
};
warn $@ if $@;

WriteMakefile(
    NAME		=> 'Dpchrist::ExtUtils::MakeMaker',
    VERSION_FROM	=> 'lib/Dpchrist/ExtUtils/MakeMaker.pm',
    PREREQ_PM		=> {
	Capture::Tiny		=> 0,
	File::Slurp		=> 0,
    },
    ABSTRACT_FROM	=> 'lib/Dpchrist/ExtUtils/MakeMaker.pm',
    AUTHOR		=>
	    'David Paul Christensen dpchrist@holgerdanske.com',
    clean		=> {
	FILES => q( *~tmp */*~tmp *.tar debug.log )
    },
);

#######################################################################
