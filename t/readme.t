# $Id: readme.t,v 1.4 2010-12-09 21:17:16 dpchrist Exp $

use Test::More;

eval { `pod2text --help 2>&1` };
if ($! || $@) {
    plan skip_all => "pod2text: $!";			# calls exit 0
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

my ($r, $s);
my ($stdout, $stderr);
my $o = bless {}, 'Foo';

($stdout, $stderr) = capture {
    $r = eval {
	Dpchrist::ExtUtils::MakeMaker::readme();
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
	Dpchrist::ExtUtils::MakeMaker::readme($o);
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
	$s = 'nosuchfile';
	Dpchrist::ExtUtils::MakeMaker::readme($o, $s);
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
    Data::Dumper->Dump([$o, $s, $stdout, $stderr, $r, $@],
		     [qw(o   s   stdout   stderr   r   @)]),
);

$r = eval {
    $s = join '', __FILE__, __LINE__, '~tmp';
    write_file($s, __FILE__, __LINE__);
    Dpchrist::ExtUtils::MakeMaker::readme($o, $s);
};
ok (								#     4
    !$@
    && defined $r
    && $r =~ /README.+$s/s,
    'call with correct arguments should generate Makefile fragment'
) or confess join(' ',
    Data::Dumper->Dump([$o, $s, $r, $@],
		     [qw(o   s   r   @)]),
);

