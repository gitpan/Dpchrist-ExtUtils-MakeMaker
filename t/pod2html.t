# $Id: pod2html.t,v 1.6 2010-12-19 06:45:30 dpchrist Exp $

use Capture::Tiny		qw( capture );
use Test::More;

my ($stdout, $stderr) = capture { system 'pod2html --help' };
plan skip_all => "command 'pod2html' not installed"
    unless $stderr =~ /Usage:.*pod2html/;

plan tests			=> 4;

use Dpchrist::ExtUtils::MakeMaker;

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
    $s = join ' ', basename(__FILE__), __LINE__, '~tmp';
    my $s2 = join("\n",
	'package'     . basename(__FILE__) .       __LINE__ . ';',
	'$VERSION = ' . basename(__LINE__) . '.' . __LINE__ . ';',
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

