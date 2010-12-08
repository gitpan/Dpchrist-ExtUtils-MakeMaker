#######################################################################
# $Id: MakeMaker.pm,v 1.19 2010-12-08 19:30:57 dpchrist Exp $
#######################################################################
# package:
#----------------------------------------------------------------------

package Dpchrist::ExtUtils::MakeMaker;

use constant DEBUG		=> 0;

use strict;
use warnings;

our $VERSION  = sprintf "%d.%03d", q$Revision: 1.19 $ =~ /(\d+)/g;

#######################################################################
# uses:
#----------------------------------------------------------------------

use Carp			qw( cluck confess );
use Data::Dumper;
use File::Basename;
use File::Spec::Functions;

#######################################################################

=head1 NAME

Dpchrist::ExtUtils::MakeMaker - additional Makefile targets and rules


=head1 SYNOPSIS

    # Makefile.PL

    package Dpchrist::ExtUtils::MakeMaker;	# for symbols

    use ExtUtils::MakeMaker;

    eval {
	require Dpchrist::ExtUtils::MakeMaker;
	die 'Skipping Dpchrist::ExtUtils::MakeMaker'
	    unless 1.013 <= $Dpchrist::ExtUtils::MakeMaker::VERSION;
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
	# ...
    );


=head1 DESCRIPTION

This documentation describes module revision $Revision: 1.19 $.


This is alpha test level software
and may change or disappear at any time.


This module contains override routines for ExtUtils::MakeMaker
which add optional rules and/or targets to the Makefile
generated by WriteMakefile().

=cut

#######################################################################

=head2 CLASS METHODS

=cut

#----------------------------------------------------------------------

=head3 import

    import Dpchrist::ExtUtils::MakeMaker (
	SECTION => CODEREF,
	SECTION => CODEREF,
	SECTION => CODEREF,
    );

Daisy-chains subroutine CODEREF 
into the Makefile override for given SECTION.
Any previous override function (e.g. &MY::SECTION)
will be called before CODEREF
and it's output passed as the first argument to CODEREF.
CODEREF should return a scalar string containing
the net text to be placed in the appropriate Makefile section.

=cut

sub import
{
    print join(' ', __FILE__, __LINE__, (caller(0))[3], 'call',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) if DEBUG;

    my $class = shift;
    print Data::Dumper->Dump([$class], [qw(class)]) if DEBUG;

    confess join(' ',
	'ERROR: arguments must be key => value pairs',
	Data::Dumper->Dump([$class, \@_], [qw(class *@)]),
    ) if @_ % 2;

    my %args = @_;

    foreach my $section (sort keys %args) {

	my $sym = join '::', 'MY', $section;
	print Data::Dumper->Dump([$sym], [qw(sym)]) if DEBUG;

	my $rc_arg = $args{$section};
	print Data::Dumper->Dump([\$rc_arg], [qw(*rc_arg)]) if DEBUG;

	print Data::Dumper->Dump([\%MY::], [qw(*MY::)]) if DEBUG;

	### The next statement seems to create a symbol table entry for
	### MY::$section even if none previously existed, and
	### $rc_prev seems to be defined in any case:

	my $rc_prev = eval {
	    no strict 'refs';
	    \&{$sym};
	};
	print Data::Dumper->Dump([\$rc_prev], [qw(*rc_prev)]) if DEBUG;
	print Data::Dumper->Dump([\%MY::], [qw(*MY::)]) if DEBUG;

	### Create new override subroutine (closure):

	my $override = sub
	{
	    print join(' ', __FILE__, __LINE__, $sym, 'call',
		Data::Dumper->Dump([\@_], [qw(*_)]),
	    ) if DEBUG;
	    
	    my $self = shift;

	    ### Call previous MY::$section override.
	    ### Ignore warning if there was none:
	    my $prev = eval { &$rc_prev($self) };
	    confess $@ if $@ && $@ !~
		/Can't call method "SUPER::\w+" on an undefined value/;

	    print Data::Dumper->Dump([$prev], [qw(prev)]) if DEBUG;

	    ### Call override provided as argument to import():
	    my $frag = eval { &$rc_arg($self, $prev) };
	    confess $@ if $@;

	    print join(' ', __FILE__, __LINE__, $sym, 'return',
		Data::Dumper->Dump([$frag], [qw(frag)]),
	    ) if DEBUG;
	    return $frag;
	};
	print Data::Dumper->Dump([$override], [qw(override)]) if DEBUG;

	### put override into MY:: symbol table:

	{
	    no warnings 'redefine';
	    no strict 'refs';

    	    *{$sym} = $override;
	}
	print Data::Dumper->Dump([\%MY::], [qw(*MY::)]) if DEBUG;
    }

    print join(' ', __FILE__, __LINE__, (caller(0))[3], "return\n")
	if DEBUG;
    return;
}

#######################################################################

=head2 OVERRIDE SUBROUTINES

=cut

#======================================================================

=head3 mcpani

    my $frag = mcpani(OBJECT, AUTHORID);

Returns Makefile fragment for target 'mcpani'
which adds the distribution tarball
to the MCPAN working directory (repository)
and pushes it to the MCPAN local directory
when the following commands are issued:

    $ make dist
    $ make mcpani

Note that you need to run 'make dist'
to create the distribution tarball
before running 'make mcpani'.

OBJECT is the object provided by ExtUtils::MakeMaker internals.

AUTHORID is used for the --authorid
parameter to 'mcpani'.
Default is 'NONE'.
I put my CPAN author id (DPCHRIST)
into an environment variable CPAN_AUTHORID in my .bash_profile:

    # .bash_profile
    export CPAN_AUTHORID=DPCHRIST

I then use this environment variable in Makefile.PL:

    # Makefile.PL
    mcpani => $ENV{CPAN_AUTHORID},

You will need a working CPAN::Module::Inject installation
before running 'make mcpani'.  See the following for details:

    perldoc mcpani
    http://www.ddj.com/web-development/184416190
    http://www.stonehenge.com/merlyn/LinuxMag/col42.html

I set an environment variable in .bash_profile that points to my
mcpani configuration file:

    # .bash_profile
    export MCPANI_CONFIG=$HOME/.mcpanirc

Here is my mcpani configuration file:

    # .mcpanirc
    local: /mnt/z/mirror/MCPAN
    remote: ftp://ftp.cpan.org/pub/CPAN ftp://ftp.kernel.org/pub/CPAN
    repository: /home/dpchrist/.mcpani
    passive: yes
    dirmode: 0755

My staging directory is ~/.mcpani.

/mnt/z/mirror/MCPAN is directory on my web server
that is served as http://mirror.holgerdanske.com/MCPAN/.

I can then run cpan on my machines
and have them use the web mirror to fetch my modules
(I only needed to do this once):

    $ sudo cpan
    cpan[1]> o conf urllist http://mirror.holgerdanske.com/MCPAN/
    cpan[2]> o conf commit
    cpan[3]> reload index

Whenever I inject a new or updated module,
I need to reload the cpan index
before I install the module:

    $ sudo cpan
    cpan[1]> reload index
    cpan[2]> install MyModule

=cut

#----------------------------------------------------------------------

sub mcpani
{
    print join(' ', __FILE__, __LINE__, (caller(0))[3], 'call',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) if DEBUG;

    my $frag = '';

    unless (@_ == 2) {
	cluck join(' ', __FILE__, __LINE__, (caller(0))[3],
	    'WARNING: requires exactly two arguments',
	    "not generating Makefile target 'mcpani'",
	);
	goto DONE;
    }

    my $r = eval { `mcpani --help 2>&1` };
    if ($! || $@ || !$r) {
	warn "Skipping 'mcpani': $!";
	goto DONE;
    }

    my $object = shift;

    my ($auth) = @_;

    unless (defined $auth && !ref($auth) && $auth =~ /^\w+$/) {
	cluck join(' ',
	    'WARNING: bad CPAN author ID --',
	    "not generating Makefile target 'mcpani'",
	    Data::Dumper->Dump([$auth], [qw(auth)]),
	);
	goto DONE;
    }

    $frag .= <<EOF;

mcpani ::

	mcpani --add \\
	--module \$(NAME) \\
	--authorid $auth \\
	--modversion \$(VERSION) \\
	--file \$(DISTVNAME).tar.gz

	mcpani --inject -v
EOF

  DONE:

    print join(' ', __FILE__, __LINE__, (caller(0))[3], 'return',
	Data::Dumper->Dump([$frag], [qw(frag)]),
    ) if DEBUG;
    return $frag;
}

#======================================================================

=head3 pod2html

    my $frag = pod2html(OBJECT, LIST);

Returns Makefile fragment for target 'all'
which will run 'pod2html' against the files in LIST
(e.g. Perl modules and scripts)
using the commands:

    pod2html FILE > PACKAGE-VERSION.html
    rm -f pod2htm?.tmp

PACKAGE and VERSION are determined by reading FILE:

* The namespace of the first 'package' decalaration found
is used for PACKAGE.
If no 'package' declaration is found,
File::Basename::basename(FILE) is used for PACKAGE.

* The argument of the first '$VERSION' variable assignment found
is evaluated and used for VERSION.

OBJECT is the object provided by ExtUtils::MakeMaker internals.

HTML files will be generated or updated
whenever the following commands are issued:

    $ make

Or,

    $ make all

If there is only one FILE,
it may be given as the argument to import():

    pod2html => FILE,

=cut

#----------------------------------------------------------------------

sub pod2html
{
    print join(' ', __FILE__, __LINE__, (caller(0))[3], 'call',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) if DEBUG;

    my $frag = '';

    unless (1 < @_) {
	cluck join(' ', __FILE__, __LINE__, (caller(0))[3],
	    'WARNING: requires two or more arguments',
	    "not adding Makefile rules 'pod2html'",
	);
	goto DONE;
    }

    my $r = eval { `pod2html --help 2>&1` };
    if ($! || $@ || !$r) {
	warn "Skipping 'pod2html': $!";
	goto DONE;
    }

    my $object = shift;

    my @files = @_;

    foreach my $file (@files) {

	unless (defined $file && !ref($file) && -e $file) {
	    cluck join(' ',
		'WARNING: bad file name argument --',
		"not adding Makefile rules 'pod2html'",
		Data::Dumper->Dump([$file], [qw(file)]),
	    );
	    next;
	}

	my $package;
	my $version;
	open(F, $file)
	    or confess join(' ',
		"Failed to open file '$file': $!",
	    );
	my $inpod = 0;
	while (<F>) {
    	    $inpod = 1 if $_ =~ /^=\w/;
	    $inpod = 0 if $_ =~ /^=cut/;
	    next if $inpod;

	    $package = $1
		if $_ =~ /^package\s+([\w\:]+);/;
	    $version = eval $1
		if $_ =~ /\$VERSION\s+=\s+(.+)/;
	    last if $package && $version;
	}
	close F
	    or confess "Failed to close file '$file': $!";

	$package = basename($file) unless $package;

	confess join(' ',
	    "Unable to find package name and/or version",
	    "for file '$file'",
	    Data::Dumper->Dump([$package, $version],
			     [qw(package   version)]),
	) unless $package && $version;

	$package =~ s/\:\:/-/g;

	my $html = $package . '-' . $version . '.html';

    	$frag .= <<EOF;

all :: $html

$html :: $file
	pod2html \$< > $html
	rm -f pod2htm?.tmp
EOF

    }

  DONE:

    print join(' ', __FILE__, __LINE__, (caller(0))[3], 'return',
	Data::Dumper->Dump([$frag], [qw(frag)]),
    ) if DEBUG;
    return $frag;
}

#======================================================================

=head3 readme

    my $frag = readme(OBJECT, FILE);

Returns Makefile fragment for target 'all'
which will run 'pod2text' against FILE
using the command:

    pod2text FILE > README

OBJECT is the object provided by ExtUtils::MakeMaker internals.

The README file will be generated or updated
whenever the following commands are issued:

    $ make

Or,

    $ make all

=cut

#----------------------------------------------------------------------

sub readme
{
    print join(' ', __FILE__, __LINE__, (caller(0))[3], 'call',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) if DEBUG;

    my $frag = '';

    unless (@_ == 2) {
	cluck join(' ', __FILE__, __LINE__, (caller(0))[3],
	    'WARNING: requires exactly two arguments',
	    "not generating Makefile target 'README'",
	);
	goto DONE;
    }

    my $r = eval { `pod2text --help 2>&1` };
    if ($! || $@ || !$r) {
	warn "Skipping 'README': $!";
	goto DONE;
    }

    my $object = shift;

    my ($file) = @_;

    unless (defined $file && !ref($file) && -e $file) {
	cluck join(' ',
	    'WARNING: bad file name argument --',
	    "not generating Makefile target 'README'",
	    Data::Dumper->Dump([$file], [qw(file)]),
	);
	goto DONE;
    }

    $frag .= <<EOF;

all :: README

README :: $file
	pod2text \$< > README
EOF

  DONE:

    print join(' ', __FILE__, __LINE__, (caller(0))[3], 'return',
	Data::Dumper->Dump([$frag], [qw(frag)]),
    ) if DEBUG;
    return $frag;
}

#======================================================================

=head3 release

    my $frag = release(OBJECT, RELEASE_ROOT);

Returns Makefile fragment for target 'release'
which copies all *.tar.gz and *.html files
to a subdirectory under RELEASE_ROOT
that is named after the module
(changing double colons to a single dash)
when the following commands are issued:

    $ make dist
    $ make release

Note that you should run 'make dist'
to create the distribution tarball before running 'make mcpani'.

OBJECT is the object provided by ExtUtils::MakeMaker internals.

I set an environment variable in my .bash_profile:

    # .bash_profile
    export RELEASE_ROOT=/mnt/z/data/release

and use this environment variable in Makefile.PL:

    # Makefile.PL
    release => $ENV{RELEASE_ROOT},

=cut

#----------------------------------------------------------------------

sub release
{
    print join(' ', __FILE__, __LINE__, (caller(0))[3], 'call',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) if DEBUG;

    my $frag = '';

    unless (@_ == 2) {
	cluck join(' ', __FILE__, __LINE__, (caller(0))[3],
	    'WARNING: requires exactly two arguments',
	    "not generating Makefile target 'release'",
	);
	goto DONE;
    }

    my $object = shift;

    my ($root) = @_;

    unless (defined $root && !ref($root) && -d $root) {
    	cluck join(' ',
    	    'WARNING: bad directory name argument --',
    	    "not generating Makefile target 'release'",
    	    Data::Dumper->Dump([$root], [qw(root)]),
	);
	goto DONE;
    }

    $frag .= <<EOF;

release ::
	mkdir -p $root/\$(DISTNAME)
	cp -i *.tar.gz *.html $root/\$(DISTNAME)
EOF

  DONE:

    print join(' ', __FILE__, __LINE__, (caller(0))[3], 'return',
	Data::Dumper->Dump([$frag], [qw(frag)]),
    ) if DEBUG;
    return $frag;
}

#######################################################################
# end of code:
#----------------------------------------------------------------------

1;

__END__

#######################################################################

=head2 EXPORT

None.


=head1 INSTALLATION

Old school:

    $ perl Makefile.PL
    $ make
    $ make test
    $ make install

Minimal:

    $ cpan Dpchrist::ExtUtils::MakeMaker

Complete:

    $ cpan Bundle::Dpchrist


=head2 PREREQUISITES

See Makefile.PL in the source distribution root directory.


=head1 SEE ALSO

    mcpani
    pod2text
    pod2html
    ExtUtils::MakeMaker
    ExtUtils::MM_Unix
    Programming Perl, 3 e., Ch. 29 "use" (pp. 822-823).
    Mastering Perl, Ch 10 "Replacing Module Parts" (pp. 160-162).


=head1 AUTHOR

David Paul Christensen dpchrist@holgerdanske.com


=head1 COPYRIGHT AND LICENSE

Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
USA.

=cut

#######################################################################