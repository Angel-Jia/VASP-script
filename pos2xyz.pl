#!/usr/bin/env perl
#;-*- Perl -*-

use FindBin qw($Bin);

`$Bin/pos2con.pl $ARGV[0]`;
`$Bin/con2xyz.pl $ARGV[0].con`;
`rm $ARGV[0].con`;

