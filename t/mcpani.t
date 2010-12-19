# $Id: mcpani.t,v 1.6 2010-12-19 06:48:24 dpchrist Exp $

use Capture::Tiny		qw( capture );
use Test::More;

my ($stdout, $stderr) = capture { system 'mcpani --help' };
plan skip_all => "command 'mcpani' not installed" if $stderr;

plan tests			=> 4;

use Dpchrist::ExtUtils::MakeMaker;

use Capture::Tiny		qw( capture );
use Carp;
use Data::Dumper;
use ExtUtils::MakeMaker;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my ($r, $s);
my $o = bless {}, 'Foo';

($stdout, $stderr) = capture {
    $r = eval {
	Dpchrist::ExtUtils::MakeMaker::mcpani();
    };
};
ok (								#     1
    !$@
    && defined $r
    && $r eq ''
    && $stderr =~ /WARNING: requires exactly two arguments/s,
    'call with no arguments should return empty string ' .
    'and issue warning'
) or confess join(' ',
    Data::Dumper->Dump([$o, $stdout, $stderr, $r, $@],
		     [qw(o   stdout   stderr   r   @)]),
);

($stdout, $stderr) = capture {
    $r = eval {
	Dpchrist::ExtUtils::MakeMaker::mcpani($o);
    };
};
ok (								#     2
    !$@
    && defined $r
    && $r eq ''
    && $stderr =~ /WARNING: requires exactly two arguments/s,
    'call with one argument should return empty string ' .
    'and issue warning'
) or confess join(' ',
    Data::Dumper->Dump([$o, $stdout, $stderr, $r, $@],
		     [qw(o   stdout   stderr   r   @)]),
);

($stdout, $stderr) = capture {
    $r = eval {
	Dpchrist::ExtUtils::MakeMaker::mcpani($o, undef);
    };
};
ok (								#     3
    !$@
    && defined $r
    && $r eq ''
    && $stderr =~ /WARNING.*bad argument AUTHORID/s,
    'call with bad CPAN author ID should return empty string ' .
    'and generate warning'
) or confess join(' ',
    Data::Dumper->Dump([$o, $stdout, $stderr, $r, $@],
		     [qw(o   stdout   stderr   r   @)]),
);

$r = eval {
    $s = 'AuThOrId';
    Dpchrist::ExtUtils::MakeMaker::mcpani($o, $s);
};
ok (								#     4
    !$@
    && defined $r
    && $r =~ /mcpani.+$s/s,
    'call with correct arguments should generate Makefile fragment'
) or confess join(' ',
    Data::Dumper->Dump([$o, $s, $r, $@],
		     [qw(o   s   r   @)]),
);

