#!/usr/bin/env perl

# plots the PV angles and an arrow for biutiful plots

use warnings;
use strict;
use Getopt::Long;
use PDL;
use PDL::IO::Pic;
use File::Basename;
use PDL::Complex;
use PDL::IO::Misc;
# reads input
#path where the programs are located in your computer
#read from PWD/.ruta
my $ruta=`awk '{print \$1}' .ruta`;
$ruta=~s/\s+//g;
# executables
my $exe_mpplotlin="$ruta/utilerias/mpplotlin.sh";
#
# defines the variables
#
my ($idf, $od,$tag,$frec);
my ($t1,$t2);
my ($a1,$b1,$a2,$b2);
my ($ht1,$ht2);
my ($ht1n,$ht2n);
#
# gets the options from the command line
#
GetOptions(
	   "od=s" => \$od,
	   "idf=s" => \$idf,
	   "tag=s" => \$tag,
	   "frec=f" => \$frec,
	   "t1=f" => \$t1,
	   "t2=f" => \$t2,
	   "a1=f" => \$a1,
	   "b1=f" => \$b1,
	   "a2=f" => \$a2,
	   "b2=f" => \$b2,
	   "ht1=f" => \$ht1,
	   "ht2=f" => \$ht2,
	  );
#
# screen instructions
#
die <<"FIN"
angarr.pl --od=s --idf=s --tag=s  {--(a,b,ht)i=f}

             i=>float s=>string

    Generate ellipses 

    --od=path         output directory 
    --idf=path        path/input-file 
    --tag=s           tag (number or string)
    --(a,b,t,ht)i=f   i=1,2 a=semi-major b=semi-minor t=angle ht=helicity 

FIN
  unless defined $od and defined $idf and defined $tag and defined $a1 and defined $a2 and defined $b1 and defined $b2 and defined $t1 and defined $t2 and defined $ht1 and defined $ht2 and defined $frec;

# the programs begins here
#
my ($fcase, $id, $ext)=fileparse($idf, "-dat");
# file for gnuplot 
my $output1="grafica.g";
die "Can't open $output1" unless open(OUTPUT1, "> $output1");
my $filo="$od/elipse-$fcase-W_$frec.pdf";
if ( $ht1==1 ){$ht1n="\\circlearrowright"};
if ( $ht1==2 ){$ht1n="\\circlearrowleft"};
if ( $ht2==1 ){$ht2n="\\circlearrowright"};
if ( $ht2==2 ){$ht2n="\\circlearrowleft"};
if (-e $filo){
  printf "\tfile exists: skipping plot\n";
}
else{
  # generates the gnuplot file
  #$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
  # only eta
 if ( 1 eq 1){
    print OUTPUT1 <<"HASTAQUEMECANSE";
set term mp color solid latex magnification 1
set out 'fig.mp'
set multiplot
set origin 0,0
set size square
unset xtics
unset ytics
unset key
#unset border
set xrange [0:1]
set yrange [0:1]
set label 1 '\\Huge\$$ht1n\$' at .5,.5 c
set arrow 1 from .5,.5 to (.5+($a1/2.)*cos($t1*3.141592/180.)),(.5+($a1/2.)*sin($t1*3.141592/180.)) nohead
set arrow 2 from .5,.5 to (.5-($a1/2.)*cos($t1*3.141592/180.)),(.5-($a1/2.)*sin($t1*3.141592/180.)) nohead
set object 1 ellipse center .5,.5 size $a1,$b1 angle $t1 front lw 4.0  fc lt 1 fillstyle  empty border lt 1
p -1 w d
set origin .6,0
set label 1 '\\LARGE\$$ht2n\$' at .5,.5 c
set arrow 1 from .5,.5 to (.5+($a2/2.)*cos($t2*3.141592/180.)),(.5+($a2/2.)*sin($t2*3.141592/180.)) nohead
set arrow 2 from .5,.5 to (.5-($a2/2.)*cos($t2*3.141592/180.)),(.5-($a2/2.)*sin($t2*3.141592/180.)) nohead
set object 1 ellipse center .5,.5 size $a2,$b2 angle $t2 front lw 4.0  fc lt 2 fillstyle  empty border lt 2
p -1 w d
HASTAQUEMECANSE
  }
  #
  # gnuplot generates the figure
  #
  system "$exe_mpplotlin grafica 1 2 >log";
  system "cp grafica.pdf $od/elipse-$fcase-W_$frec.pdf";
  system "rm grafica.*";
  system "rm log*";
}
__END__
