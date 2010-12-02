# $Id: mcpani.t,v 1.1 2010-12-02 03:34:11 dpchrist Exp $

use Test::More tests		=> 4;

use Capture::Tiny		qw( capture );
use Carp;
use Data::Dumper;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

eval {
    require Dpchrist::ExtUtils::MakeMaker;
};
if ($@) {
    ok(1);
    ok(1);
    ok(1);
    ok(1);
    exit 0;
}

my ($r, $s);
my ($stdout, $stderr);
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
    Data::Dumper->Dump([$stdout, $stderr, $r, $@],
		     [qw(stdout   stderr   r   @)]),
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
    Data::Dumper->Dump([$stdout, $stderr, $r, $@],
		     [qw(stdout   stderr   r   @)]),
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
    && $stderr =~ /WARNING: bad CPAN author ID/s,
    'call with bad CPAN author ID should return empty string' .
    'and generate warning'
) or confess join(' ',
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
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
    Data::Dumper->Dump([$s, $r, $@], [qw(s r @)]),
);

