use strict;
use Test::Simple tests => 2;

use FileHandle;
use IPC::Open2;

sub run_offsgrep {
	my ($input, $primary, @constraints) = @_;
	my @args = ("'".$primary."'");
	while (@constraints) {
		push @args, '-o', "'".shift(@constraints)."'", "'".shift(@constraints)."'"
	}
	my $cmd = "echo '$input' | ". join(' ', './offsgrep.pl', @args);
	my $res = `$cmd`;
	return $res;
}

ok ( run_offsgrep(qq{
blah blah blah
The quick brown fox jumps over the lazy dog.

	This is the start of another paragraph...
blah blah blah
}, '^$', (
	-1, '^\S',
	1, '^\t\S',
)) eq qq{< The quick brown fox jumps over the lazy dog.
: 
> 	This is the start of another paragraph...
}
);

ok ( run_offsgrep(qq{
blah blah blah
The quick brown fox jumps over the lazy dog.

	This is the start of another paragraph...
blah blah blah
}, '^ $', (
	-1, '^\S',
	1, '^\t\S',
)) eq ''
);
