# $Id: pod2html.t,v 1.8 2010-12-20 03:51:10 dpchrist Exp $

use Dpchrist::ExtUtils::MakeMaker;

use Capture::Tiny		qw( capture );
use Test::More;

my $prog = 'pod2html';
plan skip_all => "command '$prog' not installed"
    unless (Dpchrist::ExtUtils::MakeMaker::_is_program_installed
	"$prog --help"
    );

plan tests			=> 4;

use Capture::Tiny		qw( capture );
use Carp;
use Data::Dumper;
use File::Basename;
use File::Slurp;
use ExtUtils::MakeMaker;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my ($r, $s, $s2);
my $o = bless {}, 'Foo';

($stdout, $stderr) = capture {
    $r = eval {
	Dpchrist::ExtUtils::MakeMaker::pod2html();
    };
};
ok (								#     1
    !$@
    && defined $r
    && $r eq ''
    && $stderr =~ /WARNING: requires two or more arguments/s,
    'call with no arguments should return empty string ' .
    'and issue warning'
) or confess join(' ',
    Data::Dumper->Dump([$o, $stdout, $stderr, $r, $@],
		     [qw(o   stdout   stderr   r   @)]),
);

($stdout, $stderr) = capture {
    $r = eval {
	Dpchrist::ExtUtils::MakeMaker::pod2html($o);
    };
};
ok (								#     2
    !$@
    && defined $r
    && $r eq ''
    && $stderr =~ /WARNING: requires two or more arguments/s,
    'call with one argument should return empty string ' .
    'and issue warning'
) or confess join(' ',
    Data::Dumper->Dump([$o, $stdout, $stderr, $r, $@],
		     [qw(o   stdout   stderr   r   @)]),
);

($stdout, $stderr) = capture {
    $r = eval {
	$s = 'nosuchfile';
	Dpchrist::ExtUtils::MakeMaker::pod2html($o, $s);
    };
};
ok (								#     3
    !$@
    && defined $r
    && $r eq ''
    && $stderr =~ /WARNING.*bad argument in LIST/s,
    'call with bad file name should return empty string ' .
    'and issue warning'
) or confess join(' ',
    Data::Dumper->Dump([$o, $stdout, $stderr, $r, $@],
		     [qw(o   stdout   stderr   r   @)]),
);

$r = eval {
    $s = join ' ', basename(basename(__FILE__)), __LINE__, '~tmp';
    my $s2 = join("\n",
	'package'     . basename(basename(__FILE__)) .       __LINE__ . ';',
	'$VERSION = ' . __LINE__ . '.' . __LINE__ . ';',
    );
    write_file($s, $s2);
    Dpchrist::ExtUtils::MakeMaker::pod2html($o, $s);
};
ok (								#     4
    !$@
    && defined $r
    && $r =~ /pod2html.+$s/s,
    'call with correct arguments should generate Makefile fragment'
) or confess join(' ',
    Data::Dumper->Dump([$o, $s, $s2, $r, $@],
		     [qw(o   s   s2   r   @)]),
);

