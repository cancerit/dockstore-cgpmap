#!/usr/bin/perl

use strict;
my $d;
open my $I, '<', $ARGV[0] or die $!;
{
  local $/;
  $d = <$I>;
}
close $I;
$d =~ s/\s+$/\n/;
open my $O, '>', $ARGV[0] or die $!;
print $O $d;
close $O;
