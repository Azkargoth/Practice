#!/usr/bin/env perl

# plots the electric field intensity and its vector field 

use warnings;
use strict;
use Getopt::Long;
use PDL;
use PDL::IO::Pic;
use File::Basename;
use PDL::Complex;
use PDL::IO::Misc;

#path where the programs are located in your computer
#read from PWD/.ruta
my $ruta=`awk '{print \$1}' .ruta`;
$ruta=~s/\s+//g;
# executables
my $exe_mpplotlin="$ruta/utilerias/mpplotlin.sh";
#
#
# defines the variables
#
my ($idf, $od, $lab, $tag, $tam, $a1x, $a1y, $a2x, $a2y);
my ($tx,$ty);
#
# gets the options from the command line
#
GetOptions(
    "od=s" => \$od,
    "idf=s" => \$idf,
    "tag=s" => \$tag,
    "tam=f" => \$tam,
    "a1x=f" => \$a1x,
    "a1y=f" => \$a1y,
    "a2x=f" => \$a2x,
    "a2y=f" => \$a2y,
    "tx=f" => \$tx,
    "ty=f" => \$ty,
    );
#
# screen instructions
#
die <<"FIN"
arrows.pl --od=s --idf=s --tag=s --tam=f [--a1x=f --a1y=f]

             i=>float s=>string

    Generate plots with arrows following the Reflectance spectrum

    --od=path         output directory 
    --idf=path        path/input-file 
    --tag=s           tag (number or string)
    --tam=f           size of the arrows
    --aij=f           i=1,2 j=x,y position of the two arrows
FIN
unless defined $od and defined $idf and defined $tag and defined $tam and defined $a1x and defined $a1y and defined $a2x and defined $a2y; 
#
# the programs begins here
#
my ($fcase, $id, $ext)=fileparse($idf, "-dat");
# file for gnuplot 
my $output1="grafica.g";
die "Can't open $output1" unless open(OUTPUT1, "> $output1");
my $filo="$od/$fcase-W_$a1x.pdf";
$a1x=sprintf "%.4f", $a1x;
if (-e $filo){
  printf "\tfile exists: skipping plot\n";
}
else{
# generates the gnuplot file
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
print OUTPUT1 <<"HASTAQUEMECANSE";
set term mp color solid latex magnification 1
set out 'fig.mp'
set title '$a1x (eV)'
set ylabel '\\Large R'
set xlabel '\\Large photon-energy (eV)'
set key right spacing 1.2
set yrange [0:1.1]
f=$tam
set arrow 1 from $a1x,$a1y+f to $a1x,$a1y lt 1 
set arrow 2 from $a2x,$a2y+f to $a2x,$a2y lt 2 
p 'gato.dat' u 1:2  w p lt 1  t '',\\
  'gato.dat' u 1:3  w p lt 2  t ''
HASTAQUEMECANSE
#
# gnuplot generates the figure
#
system "$exe_mpplotlin grafica 1 2 >log";
system "cp grafica.pdf $od/$fcase-W_$a1x.pdf";
system "rm grafica.*";
system "rm log*";
}
__END__

