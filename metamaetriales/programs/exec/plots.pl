#!/usr/bin/env perl
#!/usr/bin/perl
#!/usr/local/bin/perl
#/opt/local/bin/perl -w

# plots the electric field intensity and its vector field 

use warnings;
use strict;
use Getopt::Long;
#use PDL;
#use PDL::NiceSlice;
#use PDL::IO::Pic;
use File::Basename;
#use PDL::Complex;
#use PDL::IO::Misc;

#
# defines the variables
#
my ($Nx, $Ny, $idf, $od, $cell, $lab, $tag, $zmin, $zmax);
#
# gets the options from the command line
#
GetOptions(
    "Nx=i" => \$Nx, 
    "Ny=i" => \$Ny, 
    "od=s" => \$od,
    "idf=s" => \$idf,
    "cell=i" => \$cell,
    "tag=s" => \$tag,
    "zmin=f" => \$zmin,
    "zmax=f" => \$zmax,
    );
#
# screen instructions
#
die <<"FIN"
plots.pl --Nx=i --Ny=i --od=s --idf=s --cell=i --tag=s [--zmin=f] [--zmax=f]

                  i=>integer s=>string

    Generate E-field intensity plots with the corresponding vector field

    --N(x,y)=i        pixels along (x,y)
    --od=path         output directory 
    --idf=path        path/input-file (starts with 'e' and ends with 'dat')
    --cell=i          1=>1x1, 2=>2x2
    --tag=s           tag (number or string)
    --zmax=f          absolute maximum field over all files
    --zmin=f          absolute minumum field over all files

FIN
unless defined $Nx and defined $Nx  and defined $od and defined $cell and defined $tag and defined $idf; 
#
# the programs begins here
#
# gets the data file and directory name
my ($fcase, $id, $ext)=fileparse($idf, "dat");
my $case="$fcase$ext";
# gets the angles, if axes=crystal the angle1 is 0 and angle2=90
# otherwise gets the angles that comes with the name of the e-* file
my $n1;
my $cual;
($n1,$n1,$n1,$n1,$cual)=split('_',$fcase,6);
my $angles;
my $angle1;
my $angle2;
my $este;
my $n3;
my $dir;
my $ea1=0;
my $ea2=0;
my $eb1=0;
my $eb2=0;
my ($alpha,$beta);
my ($alpha2,$beta2);
if ("$cual"eq"principal") {
($n3,$este)=split('principal_',$fcase,2);
($angles,$n3)=split('_',$este,2);
($n3,$dir)=split('dir_',$este,2);
($dir)=split('-',$dir,2);
($angle1,$angle2,$ea1,$eb1,$ea2,$eb2)=split(',',$angles,6);
printf "\taa1=$angle1 aa2=$angle2 a1=$ea1 b1=$eb1 a2=$ea2 b2=$eb2\n";
$ea1="0" if(!defined $ea1);
$eb1="0" if(!defined $eb1);
$ea2="0" if(!defined $ea2);
$eb2="0" if(!defined $eb2);
}
if ("$cual"eq"crystal") {
$angle1="0"
}
# extracts the frequency
# WARNING so far works for epsb=file 
my $frec;
my ($ini,$fin)=($1,$2) if $case=~/^e-(.*)W(.*)-dat/; 
($ini,$fin)=($1,$2) if $case=~/^p-(.*)W(.*)-dat/; 
($frec)=($1) if $fin=~/(.*)_epsb(.*)/; 
if ("$cual"eq"principal") {
  if ("$este"eq"vsw"){
    ($frec)=split('_epsa',$fin,2);
  }
}
($n3,$este)=split('principal_',$fcase,2);
#print "\n\tenergy=$frec eV\n";
# file for gnuplot 
my $output1="grafica.gnu";
die "Can't open $output1" unless open(OUTPUT1, "> $output1");
# 1x1 plot
if($cell == 1){
$lab="1x1";
#print "\n";
#print "doing a $lab plot\n";
my $Rx=($Nx-1);
my $Ry=($Ny-1);
# generates the gnuplot file
# terminal type
#set term x11 size 1000,1000
print OUTPUT1 <<"HASTAQUEMECANSE";
set terminal png crop truecolor size 1000,1000
set out 'nem.png'
set view map
set style data pm3d
HASTAQUEMECANSE

print OUTPUT1 "set ticslevel 0\n";
# title with energy value
#print OUTPUT1 "set title \"$frec eV\"\n";
# number of pixels-1
print OUTPUT1 "Rx=$Rx\n";
print OUTPUT1 "Ry=$Ry\n";
#set xlabel "x" 
print OUTPUT1 "set xrange [0:Rx]\n";
#set ylabel "y" 
print OUTPUT1 "set yrange [0:Ry]\n";
print OUTPUT1 "unset key\n";
print OUTPUT1 "set size square 1,1\n";
# files
print OUTPUT1 "efield='$id$case'\n";
print OUTPUT1 "vfield='$id$case-v'\n";
print OUTPUT1 "set cbrange [$zmin:$zmax]\n" if defined $zmin and defined $zmax;
print OUTPUT1 "set log cb\n";
# plot
print OUTPUT1 "sp efield u 1:2:3,vfield u (\$1-.5*\$3):(\$2-.5*\$4):(\$2-\$2):(\$3):(\$4):(\$4-\$4) w vec  lt 2\n";
print OUTPUT1 "
d=.05
theta=$angle1*3.141592/180
set label 1 \"X\" at d*1.05*cos(theta),d*1.05*sin(theta)  tc lt 4 font \",2\" left front 
set label 2 \"Y\" at -d*1.05*sin(theta),d*1.05*cos(theta)  tc lt 4 font \",2\" left front 
";
print OUTPUT1 "
unset xtics 
unset ytics 
unset title
unset border
set xrange [-.1:.1] 
set yrange [-.1:.1] 
p  1/0 w d\n";
}
if($cell == 2){
$lab="2x2";
my $Cx=(2*$Nx-2);
my $Cy=(2*$Ny-2);
my $Rx=($Nx-1);
my $Ry=($Ny-1);
# generates the gnuplot file
# terminal type
#set term x11 size 1000,1000
print OUTPUT1 "set terminal png crop truecolor size 1000,1000\n";
print OUTPUT1 "set out 'nem.png'\n";
#
print OUTPUT1 "set view map\n"; 
print OUTPUT1 "set style data pm3d\n";
print OUTPUT1 "set ticslevel 0\n";
print OUTPUT1 "set multiplot\n";
# title with energy value
#print OUTPUT1 "set title \"$frec eV\"\n";
# number of pixels-1
print OUTPUT1 "Rx=$Rx\n";
print OUTPUT1 "Ry=$Ry\n";
# doubles the plotting area
print OUTPUT1 "Cx=$Cx\n";
print OUTPUT1 "Cy=$Cy\n";
#set xlabel "x" 
print OUTPUT1 "set xrange [0:Cx]\n";
#set ylabel "y" 
print OUTPUT1 "set yrange [0:Cy]\n";
print OUTPUT1 "unset key\n";
print OUTPUT1 "set size square 1,1\n";
# files
print OUTPUT1 "efield='$id$case'\n";
print OUTPUT1 "vfield='$id$case-v'\n";
print OUTPUT1 "set cbrange [$zmin:$zmax]\n" if defined $zmin and defined $zmax;
print OUTPUT1 "set log cb\n";
# plot
print OUTPUT1 "sp efield u 1:2:3,\\
efield u (\$1+Rx):2:3,\\
efield u 1:(\$2+Ry):3,\\
efield u (\$1+Rx):(\$2+Ry):3,\\
vfield u (\$1-.5*\$3):(\$2-.5*\$4):(\$2-\$2):(\$3):(\$4):(\$4-\$4) w vec  lt 2,\\
vfield u (\$1-.5*\$3+Rx):(\$2-.5*\$4):(\$2-\$2):(\$3):(\$4):(\$4-\$4) w vec  lt 2,\\
vfield u (\$1-.5*\$3):(\$2-.5*\$4+Ry):(\$2-\$2):(\$3):(\$4):(\$4-\$4) w vec  lt 2,\\
vfield u (\$1-.5*\$3+Rx):(\$2-.5*\$4+Ry):(\$2-\$2):(\$3):(\$4):(\$4-\$4) w vec  lt 2\n";
# axes COMMENTED 
#print OUTPUT1 "
#d=.05
#";
#if ("$dir"eq"xp"or"$dir"eq"xx"){
#print OUTPUT1 "theta=$angle1*3.141592/180";
#print OUTPUT1 "
#set label 1 \"X\" at d*1.05*cos(theta),d*1.05*sin(theta)  tc lt 4 font \",2\" left front 
#set label 2 \"Y\" at -d*1.05*sin(theta),d*1.05*cos(theta)  tc lt 4 font \",2\" left front 
#";
#print OUTPUT1 "
#set arrow 1 from 0,0,0 to d*cos(theta),d*sin(theta),0 lt 1 lw 6
#";
#print OUTPUT1 "
#set arrow 2 from 0,0,0 to -d*cos(theta),-d*sin(theta),0 lt 1 lw 6
#";
#}
#if ("$dir"eq"yp"or"$dir"eq"yy"){
#print OUTPUT1 "theta=$angle2*3.141592/180";
#print OUTPUT1 "
#set arrow 1 from 0,0,0 to d*cos(theta),d*sin(theta),0 lt 3 lw 6
#";
#print OUTPUT1 "
#set arrow 2 from 0,0,0 to -d*cos(theta),-d*sin(theta),0 lt 3 lw 6
#";
#}
print OUTPUT1 "
unset xtics 
unset ytics 
unset title
unset border
set xrange [-.1:.1] 
set yrange [-.1:.1] 
ea1=$ea1
eb1=$eb1
ea2=$ea2
eb2=$eb2
";
if ("$dir"eq"xp"or"$dir"eq"xx"){
print OUTPUT1 "theta=$angle1
";
print OUTPUT1 "set object 1 ellipse center 0,0 size ea1*.05,eb1*.05 angle theta front lw 4.0 fc lt -1 fillstyle empty border lt -1 
";
#print OUTPUT1 "set label 5 
}
if ("$dir"eq"yp"or"$dir"eq"yy"){
print OUTPUT1 "theta=$angle2
";
print OUTPUT1 "set object 1 ellipse center 0,0 size ea2*.05,eb2*.05 angle theta front lw 4.0  fc lt 1 fillstyle  empty border lt 1
"; 
}
print OUTPUT1 "p  1/0 w d\n";
}
#
# gnuplot generates the figure
#
system "gnuplot grafica.gnu > log";
#system "cp nem.png $od/rem-$tag.png";
system "mv nem.png $od$case.$lab.png";
#
# output file name for the png figure
#
my $outfile="$od$case.$lab.png";
#print "\n";
#print "Output: $outfile\n";
#print "\n";
system "rm grafica.gnu log*";

