#!/usr/bin/env perl
#######################

use strict;
use Pod::Usage;
use Getopt::Long;
use File::Basename;
#
# executables
#path where the programs are located in your computer
#read from PWD/.ruta
my $ruta=`awk '{print \$1}' .ruta`;
$ruta=~s/\s+//g;
my $execawk="$ruta/chose-column.awk";
# reads input
# Options
my $od; #output directory
my $scale; #scale
my $angle; #angle
my $Nh;#Haydock's coefficients
my $epsa;#material or value R-I
my $epsb;#material or value R-I
my $axes;#crystal or principal
my $nem;#ave=>average or vsw=>vs energy
my $ep;#e=>Electric field, p=>Polarization
my $keep;#keep the files for the movies
#path for dedinitions.tex
#read from PWD/.defi
my $defi=`awk '{print \$1}' .defi`;
$defi=~s/\s+//g;
#
GetOptions(
	   "od=s" => \$od,
	   "scale=f" => \$scale,
	   "angle=f" => \$angle,
	   "Nh=i" => \$Nh,
	   "epsa=s" => \$epsa,
	   "epsb=s" => \$epsb,
	   "axes=s" => \$axes,
	   "nem=s" => \$nem,
	   "ep=s" => \$ep,
	   "keep" => \$keep,
	  );
#
# screen instructions
#
die <<"FIN"

corre-3g.pl --od=s --scale=f --angle=f --Nh=i --epsa=s --epsb=s --axes=s [--nem=s] --ep=s

             s=>string f=>real i=integer 

    Generate plots with arrows following the Reflectance&Angle spectrum

    --od=path         output directory 
    --scale=f         scale
    --angle=f         angle
    --Nh=i            Haydock's coefficients            
    --epsa=s          material or value R-I
    --epsb=s          material or value R-I
    --axes=s          crystal or principal
    --nem=s           ave=>average or vsw=>vs energy
    --ep=s            e=>Electric field, p=>Polarization
    --keep            keep the files for the movies

FIN
  unless defined $od and defined $scale and defined $angle and defined $Nh and defined $epsa and defined $epsb and defined $axes and defined $ep;

if ("$axes"ne"crystal" and "$axes"ne"principal") {
die "\n\t--axes must be crystal or principal\n\n"
}
if ("$axes"eq"principal") {
  die "\n\tprincipal axes: give a value for --nem [ave/vsw]\n\n" unless defined $nem;
}

# make list of the appropriate files with wich the movie is done sorted w.r.t. energy
if ("$axes"eq"crystal") {
system "ls plots/$ep*$angle*$scale*$Nh*$epsa*$epsb*xx*.png | sort -tW -n -k 2 > lili1";
system "ls plots/$ep*$angle*$scale*$Nh*$epsa*$epsb*yy*.png | sort -tW -n -k 2 > lili2";
}
my ($du,$ang);
if ("$axes"eq"principal") {
  if ("$nem"eq"ave"){
    system "ls plots/$ep*$angle*$scale*ave*$Nh*$epsa*$epsb*xp*.png | sort -tW -n -k 2 > lili1";
    system "ls plots/$ep*$angle*$scale*ave*$Nh*$epsa*$epsb*yp*.png | sort -tW -n -k 2 > lili2";
    #gets rotation angle of xp
    my $cuali=`head -1 lili1`;
    ($du,$ang)=split('principal_',$cuali,2);
    ($ang,$du)=split('_',$ang,2);
  }
  if ("$nem"eq"vsw"){
    # name for movie
    system "ls plots/$ep*$angle*$scale*vsw*$Nh*xp*.png | sort -tW -n -k 2 > lili1";
    system "ls plots/$ep*$angle*$scale*vsw*$Nh*yp*.png | sort -tW -n -k 2 > lili2";
  }
}
system "ls arrows/eps*$angle*$scale*$Nh*$epsa*$epsb*.pdf   | sort -tW -n -k 2 > lili3";
system "ls arrows/aa-eps*$angle*$scale*$Nh*$epsa*$epsb*.pdf   | sort -tW -n -k 2 > lili4";
# joins the 4 lists into one single list
system "paste lili1 lili2 lili3 lili4 > lili5";
# obtains the name to baptize the movie
my $cual=`head -1 lili3`;
my ($a1,$a2,$a3)=split('-',$cual,3);
my ($a4,$a5)=split('_',$a3,2);
my ($a6,$a7)=split('.pdf',$a5,2);
my ($a8,$a9)=split('-',$a6,2);
#
my $name;
if ("$axes"eq"crystal") {
$name="eps-$a2-$axes\_$a8";
}
if ("$axes"eq"principal") {
  if ("$nem"eq"ave"){
    $name="eps-$a2-$axes-$ang\_$a8";
  }
  if ("$nem"eq"vsw"){
    $name="eps-$a2-$axes-vsw";
  }
}
#printf "\t$name\n";
# obtains the helicity from meps/eps*-dat file
my ($void,$aux)=split('W_',$cual,2);
my ($aux,$epsi)=split('arrows/',$void,2);
my $dat="dat";
my $epsd="meps/$epsi$dat";
printf "\t$epsd\n";
# get the eV
system "awk -f $execawk -v colname=w $epsd > n1.rem";
# get the ht1 helicity tag 1
system "awk -f $execawk -v colname=ht1 $epsd > n2.rem";
# get the ht2 helicity tag 2
system "awk -f $execawk -v colname=ht2 $epsd > n3.rem";
# all in one file
system "paste n1.rem n2.rem n3.rem > n4.rem";
#
printf "\n";
printf "\tExtracting files according to frequency for plots\n";
my $case="lili5";
# get the number of lines, i.e. frequencies
my $NL=`wc $case | awk '{print \$1}'`;
open(FILE, "< $case");
my $n=0;
while(<FILE>){
  chomp;
  $n=($n+1);
  my ($b1, $b2, $b3, $b4)=split;
  system "cp $b1 rem1.png";
  system "cp $b2 rem2.png";
  system "cp $b3 rem3.pdf";
  system "cp $b4 rem4.pdf";
  # extracts eV
  my ($void,$aux)=split('W_',$b3,2);
  my ($eV,$aux)=split('.pdf',$aux,2);
  $eV=sprintf "%.4f", $eV;
  # extracts the helicity
  my $ht1=`awk '{if(\$1==$eV) print \$2}' n4.rem`;
  my $ht2=`awk '{if(\$1==$eV) print \$3}' n4.rem`;
  $ht1=sprintf "%.0f", $ht1;
  $ht2=sprintf "%.0f", $ht2;
  # assigns right or left
  if ( $ht1==1 ){$ht1="\\circlearrowright"};
  if ( $ht1==2 ){$ht1="\\circlearrowleft"};
  if ( $ht2==1 ){$ht2="\\circlearrowright"};
  if ( $ht2==2 ){$ht2="\\circlearrowleft"};
  printf "\tDoing plot for $eV eV $n of $NL";
  my $output="batman.tex";
  die "Can't open $output" unless open(OUTPUT, "> $output");
  print OUTPUT <<"HASTAQUEMECANSE";
\\documentclass[preprint,12pt]{revtex4}
\\usepackage[usenames,dvipsnames]{xcolor}
\\usepackage[spanish,english]{babel}
\\usepackage[utf8]{inputenc}
\\usepackage{graphicx}
\\usepackage{amsmath,mathrsfs}
\\usepackage{amssymb}
\\input{$defi}
\\pagestyle{empty}
\\begin{document}
\\begin{center}
%\\Large Non-Retarded Optical Activity {\\it On Demand}
\\includegraphics[scale=.6]{rem3}%
\\includegraphics[scale=.6]{rem4}\\\\
\\includegraphics[scale=.28]{rem1}%
\\includegraphics[scale=.28]{rem2}%\\\\
%\\hspace{.7cm}\\textcolor{red}{Incident field}
%\\hspace{5cm}\\textcolor{blue}{Incident field}
\\end{center}
\\begin{picture}(5,20)
\\put(110,131){\\Huge\$$ht1\$}
\\put(332,131){\\Huge\$\\textcolor{red}{$ht2}\$}
\\end{picture}
\\end{document}
HASTAQUEMECANSE
system "pdflatex batman > log";
system "pdfcrop batman.pdf > log";
system "mv batman-crop.pdf lrem-$n.pdf";
system "cp lrem-$n.pdf keep/$ep-lrem-$n.pdf" if $keep;
system "rm  rem*";
}
system "rm lili* batman*";
printf "\tDone!\n";
# Generates the animate movie
# file for anima.tex 
printf "\n\tDoing the movie\n";
my $output1="anima.tex";
die "Can't open $output1" unless open(OUTPUT1, "> $output1");
print OUTPUT1 <<"HASTAQUEMECANSE";
\\documentclass[dvipsnames]{beamer}
\\usepackage{animate}
\\begin{document}
\\vfill

\\begin{center}
\\animategraphics[controls,scale=.7,palindrome]{6}{lrem-}{1}{$n}
\\end{center}
\\end{document}
HASTAQUEMECANSE
system "pdflatex anima.tex > log";
system "pdflatex anima.tex > log";
system "mv anima.pdf $od/$ep-m-$name.pdf";
print  "\n\tMovie: $od/$ep-m-$name.pdf\n";
printf "\n";
system "rm  lrem*";
system "rm anima* log* n*.rem";
#
