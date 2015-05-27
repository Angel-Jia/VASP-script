#!/usr/bin/env perl
#This script is used to extract atomic coordinations and energy in each step from OUTCAR file.
#By sky nankai university
#Version 1.2
use 5.010;
use strict;
use warnings;
use vars qw($dash_label $line_number $step $line $find_position);
print "\n";
print "\n";
print "###This script extracts atomic coordinations and energy in each step from OUTCAR file###\n";
print "\n";
print "\n";
#dash_labe is used to located coordinations, which is within two rows of dashes. when dash_label=2, I set find_position=1
#find_position=1 means that we find the coordinations.
if($ARGV[0] eq ""){
    print "Usage: nebcoor.pl file1 file2 file3 ....\n";
    print "Please try again!\n";
    print "\n";
    exit 1;
}
while($ARGV[0]){
    my $outfile=$ARGV[0].'.pos';
    print "Processing $ARGV[0]\n";
    open FILE, '<', $ARGV[0] or die "Cannot open file $ARGV[0]: $!";
    open OUT, '>', $outfile or die "Cannot open file $outfile: $!";

    $line_number=0;
    $dash_label=0;
    $step=0;
    $find_position=0;
    
    while(defined($line = <FILE>)){
        $line_number++;
        if($line =~ /POSITION/){
            $step++;
            $find_position=1;
            print OUT "\nstep: $step\n";
            $dash_label=0;
            next;
        }
        if($line =~ /free  / or $line =~ /energy  without entropy/){
        print OUT "$line";
        }
        next if $find_position == 0;
        if($find_position == 1 and $line =~ /-{50,}/){
            $dash_label++;
            next;
        }
        if($dash_label == 2){
            $find_position=0;
            next;
        }
        if($find_position == 1 and $dash_label == 1){
            chomp($line);
            $line =~ s/^\s+//;
            my @coordinate = split(/\s+/, $line);
            my $force = ($coordinate[3]**2+$coordinate[4]**2+$coordinate[5]**2)**(1/2);
            printf OUT "%12.5f  %12.5f  %12.5f    ",$coordinate[0],$coordinate[1],$coordinate[2];
            printf OUT "%12.5f  %12.5f  %12.5f  %12.5f\n",$coordinate[3],$coordinate[4],
                       $coordinate[5],$force;
        }
    }  
    print "results have been saved in file $ARGV[0].pos\n";
    print "\n";
    shift @ARGV;
    close(FILE);
    close(OUT);
}
print "                  #################### Finished! ####################\n";
print "\n";
