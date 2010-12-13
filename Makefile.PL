#######################################################################
# $Id: Makefile.PL,v 1.21 2010-12-13 01:04:06 dpchrist Exp $
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

use lib './lib';

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
    die 'Skipping Dpchrist::ExtUtils::MakeMaker'
    	unless 1.021 <= $Dpchrist::ExtUtils::MakeMaker::VERSION;
    import Dpchrist::ExtUtils::MakeMaker (
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
	Capture::Tiny			=> 0.06,
	Carp				=> 1.08,
	Data::Dumper			=> 2.121_14,
	ExtUtils::MakeMaker		=> 6.54,
	File::Basename			=> 2.76,
	File::Slurp			=> 9999.13,
	File::Spec::Functions		=> 3.2501,
	Test::Compile			=> 0.10,
	Test::Manifest			=> 1.22,
	Test::More			=> 0.72,
	Test::Pod			=> 1.40,
	Test::Prereq			=> 1.037,
    },
    ABSTRACT_FROM	=> 'lib/Dpchrist/ExtUtils/MakeMaker.pm',
    AUTHOR		=>
	    'David Paul Christensen dpchrist@holgerdanske.com',
    clean		=> {
	FILES => q( *~tmp */*~tmp *.tar debug.log )
    },
    realclean		=> {
	FILES => q( README *.html *.tar.gz ),
    },
);

#######################################################################
