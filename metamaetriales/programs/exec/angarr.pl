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
my ($idf, $od, $lab, $tag, $tam, $a1x, $a1y, $a2x, $a2y, $a3x, $a3y);
my ($a4x,$a4y,$tx,$ty);
my ($ht1,$ht2);
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
	   "a3x=f" => \$a3x,
	   "a3y=f" => \$a3y,
	   "a4x=f" => \$a4x,
	   "a4y=f" => \$a4y,
	   "tx=f" => \$tx,
	   "ty=f" => \$ty,
	   "ht1=f" => \$ht1,
	   "ht2=f" => \$ht2,
	  );
#
# screen instructions
#
die <<"FIN"
angarr.pl --od=s --idf=s --tag=s --tam=f {--aij=f} {--hti}

             i=>float s=>string

    Generate plots with arrows following the Reflectance spectrum

    --od=path         output directory 
    --idf=path        path/input-file 
    --tag=s           tag (number or string)
    --tam=f           size of the arrows
    --aij=f           i=1...4 j=x,y position of the arrows
    --hti=f           i=1,2 helicity tag
FIN
  unless defined $od and defined $idf and defined $tag and defined $tam and defined $a1x and defined $a1y and defined $a2x and defined $a2y and defined $a3x and defined $a3y and defined $a4x and defined $a4y and defined $ht1 and defined $ht2; 
#
# the programs begins here
#
my ($fcase, $id, $ext)=fileparse($idf, "-dat");
# file for gnuplot 
my $output1="grafica.g";
die "Can't open $output1" unless open(OUTPUT1, "> $output1");
my $filo="$od/aa-$fcase-W_$a1x.pdf";
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
set title '$a1x (eV)'
set ylabel '\\Large \$\\eta\$ (third flattening)'
set xlabel '\\Large photon-energy (eV)'
set key right spacing 1.2
set yrange [0:1.1]
f=$tam
set zeroaxis
set arrow 3 from  $a3x,$a3y+.2 to  $a3x,$a3y lt 1 
set arrow 4 from  $a4x,$a4y+.2 to  $a4x,$a4y lt 1 
# plots third flattening= (a(i)-b(i))/(a(i)+b(i)) 
eta(x,y)=(x-y)/(x+y)
p  'gata.dat' u 1:(\$8==2? eta(\$4,\$5):1/0) w p pt 2 lt 1 t '\$\\eta_1:\\circlearrowleft\$',\\
  'gata.dat' u 1:(\$8==1? eta(\$4,\$5):1/0) w p pt 1 lt 1 t '\$\\eta_1:\\circlearrowright\$',\\
  'gata.dat' u 1:(\$9==2? eta(\$6,\$7):1/0) w p pt 2 lt 2 t '\$\\eta_2:\\circlearrowleft\$',\\
  'gata.dat' u 1:(\$9==1? eta(\$6,\$7):1/0) w p pt 1 lt 2 t '\$\\eta_2:\\circlearrowright\$'
HASTAQUEMECANSE
  }
  # angles and eta
  if ( 1 eq 2){
    print OUTPUT1 <<"HASTAQUEMECANSE";
set term mp color solid latex magnification 1
set out 'fig.mp'
set title '$a1x (eV)'
set ylabel '\\Large \$\\alpha\\,(^{\\circ})\$'
set y2label '\\Large \$\\eta\$ (third flattening)'
set xlabel '\\Large photon-energy (eV)'
set key right spacing 1.2
set yrange [-100:100]
set ytics -90,20,90
f=$tam
set zeroaxis
set arrow 1 from $a1x,$a1y+f to $a1x,$a1y lt 1 
set arrow 2 from $a2x,$a2y+f to $a2x,$a2y lt 1 
set arrow 3 from second $a3x,$a3y+.2 to second $a3x,$a3y lt 1 
set arrow 4 from second $a4x,$a4y+.2 to second $a4x,$a4y lt 1 
# plots third flattening= (a(i)-b(i))/(a(i)+b(i)) 
eta(x,y)=(x-y)/(x+y)
set y2tics
set x2tics
set ytics nomirror
set y2range [0:1.1] 
p 'gata.dat' u 1:2  w l lt 1  t '\$\\alpha_a(1)\$',\\
  'gata.dat' u 1:3  w l lt 2  t '\$\\alpha_a(2)\$',\\
  'gata.dat' u 1:(\$8==2? eta(\$4,\$5):1/0) w l lw 3 lt 1 t '\$\\eta_1:\\circlearrowleft\$' axis x1y2,\\
  'gata.dat' u 1:(\$8==1? eta(\$4,\$5):1/0) w p pt 1 lt 1 t '\$\\eta_1:\\circlearrowright\$' axis x1y2,\\
  'gata.dat' u 1:(\$9==2? eta(\$6,\$7):1/0) w l lw 3 lt 2 t '\$\\eta_2:\\circlearrowleft\$' axis x1y2,\\
  'gata.dat' u 1:(\$9==1? eta(\$6,\$7):1/0) w p pt 1 lt 2 t '\$\\eta_2:\\circlearrowleft\$' axis x1y2
HASTAQUEMECANSE
  }
  #
  # gnuplot generates the figure
  #
  system "$exe_mpplotlin grafica 1 2 >log";
  system "cp grafica.pdf $od/aa-$fcase-W_$a1x.pdf";
  system "rm grafica.*";
  system "rm log*";
}
__END__
