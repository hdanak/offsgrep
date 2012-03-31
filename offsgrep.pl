#!/usr/bin/perl
# Usage: offsgrep "...regex..." -o 1 "...regex..." -o -1 "...regex..."
use strict;
#use warnings;
#use diagnostics;

my $USAGE = "Usage: <regex> -o <offset> <regex> -o ...\n";
my @constraints = get_constraints(@ARGV) or die;
my $max_off = 0;
my $min_off = 0;
for (@constraints) {
	my $off = $_->[0];
	$max_off = $off if $off > $max_off;
	$min_off = $off if $off < $min_off;
}
my $window_size = $max_off - $min_off + 1;
my @window;
while (<stdin>) {
	push @window, $_;
	next if @window < $window_size;
	my @current;
	for my $off_reg(@constraints) {
		my $i = $off_reg->[0] - $min_off;
		last unless $window[$i] =~ /$off_reg->[1]/;
		if ($off_reg->[0] == 0) { push @current, [':', $window[$i]] }
		elsif ($off_reg->[0] == $min_off) { push @current, ['<', $window[$i]] }
		elsif ($off_reg->[0] == $max_off) { push @current, ['>', $window[$i]];
			print $_->[0], ' ', $_->[1] for @current;
		}
		else { push @current, ['|', $window[$i]] }
	}
	shift @window;
}

sub get_constraints {
	my $s = 2;
	my $p = [0];
	my @ret;
	for (@_) {
		if ($s == 0) {		# flag
			die "Incorrect flag: $_\n".$USAGE unless /^-o$/;
			$p = [];
		} elsif ($s == 1) {	# offset
			die "Incorrect offset: $_\n".$USAGE unless /^-?\d+$/;
			push @$p, int($_);
		} elsif ($s == 2) { # regex
			push @$p, $_;
			push @ret, $p;
		}
		$s == 2 ? $s = 0 : ++$s;
	}
	die "Missing regex\n".$USAGE if $s;
	return sort {$a->[0] <=> $b->[0]} @ret;
}

