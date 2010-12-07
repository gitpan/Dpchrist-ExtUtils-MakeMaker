# $Id: mcpani.t,v 1.2 2010-12-07 22:42:06 dpchrist Exp $

use Dpchrist::ExtUtils::MakeMaker;

use Test::More tests		=> 4;

use Capture::Tiny		qw( capture );
use Carp;
use Data::Dumper;
use ExtUtils::MakeMaker;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;


my $inc = $INC{'Dpchrist/ExtUtils/MakeMaker.pm'};

die join(' ',
    'incorrect path to Dpchrist::ExtUtils::MakeMaker.pm detected',
    Data::Dumper->Dump([\%INC], [qw(*INC)]),
) unless $inc =~ /lib\/Dpchrist\/ExtUtils\/MakeMaker.pm$/;

 my $version = MM->parse_version($inc);

 die join(' ',
    'incorrect Dpchrist::ExtUtils::MakeMaker.pm version detected',
    Data::Dumper->Dump([$version], [qw(version)]),
    Data::Dumper->Dump([\%INC], [qw(*INC)]),
) unless $version eq '1.018';

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
    'call with bad CPAN author ID should return empty string ' .
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

