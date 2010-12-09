# $Id: pod2html.t,v 1.4 2010-12-09 21:17:16 dpchrist Exp $

use Test::More;

eval { `pod2html --help 2>&1` };
if ($! || $@) {
    plan skip_all => "pod2html: $!"; 			# calls exit 0
}

plan tests			=> 4;

use Dpchrist::ExtUtils::MakeMaker;

use Capture::Tiny		qw( capture );
use Carp;
use Data::Dumper;
use File::Slurp;
use ExtUtils::MakeMaker;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my ($r, $s, $s2);
my ($stdout, $stderr);
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
    && $stderr =~ /WARNING: bad file name/s,
    'call with bad file name should return empty string ' .
    'and issue warning'
) or confess join(' ',
    Data::Dumper->Dump([$o, $stdout, $stderr, $r, $@],
		     [qw(o   stdout   stderr   r   @)]),
);

$r = eval {
    $s = join ' ', __FILE__, __LINE__, '~tmp';
    my $s2 = join("\n",
	'package'     . __FILE__ .       __LINE__ . ';',
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

