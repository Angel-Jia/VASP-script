#!/bin/env perl
$numb[0][0] = 1;
$numb[1][0] = 2;
$numb[2][0] = 3;

$tmp[0][0] = 4;
$tmp[1][0] = 5;
$tmp[2][0] = 6;

push(@ysk,[@numb]);
push(@ysk,[@tmp]);
$n=@tmp;

print "$n\n";
