#!/usr/bin/env perl

# plots the normal incidence reflection and transmission coefficients
# across a film made of a metamaterial 
# as a function of the angle between the incoming electric field and the x-axis
# of the metamaterial

use strict;
use Getopt::Long;
use File::Basename;
use constant pi=>4*atan2(1,1);
#path for definitions.tex
#read from PWD/.defi
#my $defi=`awk '{print \$1}' .defi`;
#$defi=~s/\s+//g;
my $defi="/Users/bms/util/definitions.tex";
#
#my $ruta=`awk '{print \$1}' .ruta`;
#$ruta=~s/\s+//g;
my $ruta="/Users/bms/research/metamaterials/haydock/fields/programs/exec";
# executables
my $exe_mpplotlin="$ruta/utilerias/mpplotlin.sh";
my $exe_rt="$ruta/tSlab.pl";
#
# defines the variables
#
my $tag;
my $df;
my $n;
my $nc;
#
# gets the options from the command line
#
GetOptions(
    "tag=s" => \$tag,
    "df=f" => \$df,
    "nc=f" => \$nc,
    );
#
# screen instructions
#
die <<"FIN"

cc=[A,S]# ; ls meps/eps-figure*\$cc*-dat | sort -t[A,S] -n -k | plot-rt.pl --tag=\$cc --df=thickness --nc=refraction-index-of-medium-c

                  s=>string

    Generate RT angle plots with the corresponding unit cell

    Give the Scale or Angle values as:
    A# or S# where #=numerical value
    In sort pick A if cc=S# or S if cc=A#
    This must agree with what you are 
    using in ls cases/figure*.png 
    Example: does all the S for a fixed A=24.00 for figure=cross

cc=A24.00 ; ls meps/eps-cross*\$cc*-dat-original |sort -tS -n -k 2 | ~/research/metamaterials/haydock/fields/programs/exec/plot-rt.pl --tag=\$cc --df=\$df --nc=\$nc

FIN
  unless defined $tag and defined $df and defined $nc;
#
# the programs begins here
#
my $caso;
# loop over files
  while(<>) {
    chomp($caso=$_);
    my ($base, $dir, $ext)=fileparse($caso, "-dat");
    my ($void,$whole)=split('eps-',$base,2);
    ($whole,$void)=split('-dat',$whole,2);
    printf "\n\tRunning: $whole \n";
    #gets data from file name
    my $data;
    my $figure;
    my $epsb;
    # figure,angle
    ($figure,$data)=split('_A',$whole,2);
    my ($angulo)=split('_S',$data,2);
    # scale
    ($void,$data)=split('_S',$whole,2);
    my ($escala)=split('_f',$data,2);
    # filling fraction
    ($void,$data)=split('_f',$whole,2);
    my ($ff)=split('_',$data,2);
    # epsa
    ($void,$data)=split('epsa_',$whole,2);
    my ($epsa)=split('_',$data,2);
    # epsb
    ($void,$epsb)=split('epsb_',$whole,2);
    #printf "\t$figure $angulo $escala $ff $epsa $epsb $n\n";
    my $fig="$figure\_A$angulo\_S$escala";
    #printf "\t$fig\n";
    # size of the tile of unit cells
    my $fsize=`file ucell/$fig.png | awk -Fx '{print \$1}' | awk -F, '{print \$2}'`;
    # scale the size
    my $scale=(603./$fsize)*.2;
    #printf "\t$scale\n";
    # generates R and T
    # loop over theta
    my $theta="-5";
    $n=0;
    while ($theta <= 175) {
      $n=($n+1);
      $theta=$theta+5;
#      $theta=$theta+10;
      printf "\tfor theta=$theta\n";
      my $outputFile="rt-$df-nm-$whole.d";
      my $plot="rt-$df-nm-$whole\_t$theta";
      my $corre="$exe_rt --if=$caso --of=$outputFile --od=rt --theta=$theta --na=1 --nc=$nc --df=$df";
      #printf "\t$corre\n";
      system $corre;
      # gnuplot
      my $output="grafica.g";
      die "Can't open $output" unless open(OUTPUT, "> $output");
      print OUTPUT <<"HASTAQUEMECANSE";
set term mp color solid latex magnification 1
set out 'fig.mp'
#
file='rt/$outputFile'
file2='/Users/bms/meetings/15/smf/talk/tr-silver.dat'
#set size square
set xlabel '\\Large \$\\hbar\\omega\$ (eV)'
set ylabel '\\Large \$ T,R\$'
set xrange [.9:3.1] 
set yrange [-.05:1.05] 
# add ht,hr to column("helicityt") to get different colors for the transmitted or reflected helicity
ht=2
hr=2
# size of the ellipses
s = 0.1
# size of funny ellipse for the key
st = 0.001
# every energy
ev=10
# label for angle
#set label 1 at 2,.9 '\\Large \$\\theta=0^\\circ\$' c
#set title '\\Large $figure \$\\alpha=$angulo\$ \$S=$escala\$ \$f=$ff\$ \$\\theta=$theta^\\circ\$' c
set title '\\Large \$\\theta=$theta^\\circ\$' c
#
set label 2 at 1.1,.925 '\\large \$R\$-silver'
set label 3 at 1.1,.05 '\\large \$T\$-silver'
#
p file every ev u "w":"T":(s*column("at")):(s*column("bt")):"anglet":(column("helicityt")+ht) w ellipses units xx lc variable lt 1 t '',\\
     '' every ev u "w":"R":(s*column("ar")):(s*column("br")):"angler":(column("helicityr")+hr) w ellipses units xx lc variable t '',\\
     '' every ev u "w":"R":(st*column("ar")):(st*column("br")):"angler" w ellipses units xx  lt 1 lw 2 t '-1 \$\\circlearrowright\$',\\
     '' every ev u "w":"R":(st*column("ar")):(st*column("br")):"angler" w ellipses units xx  lt 3 lw 2 t '+1 \$\\circlearrowleft\$',\\
     '' u "w": "T" w l lt 4 t '\\Large \$T\$',\\
     '' u "w": "R" w l lt 2 t '\\Large \$R\$',\\
file2 u 1:2 w l lt 1 t '',\\
file2 u 1:3 w l lt 1 t ''

HASTAQUEMECANSE
      #
      # gnuplot generates the figure
      #
      system "$exe_mpplotlin grafica 1 2 >log";
      system "cp grafica.pdf plots/$plot.pdf";
      #system "rm grafica.*";
      system "rm log*";
      # incident polarization plot
      my $m;
      my $tan=sin($theta*pi/180)/cos($theta*pi/180);
      $m=99 unless $tan < 100;
      $m=$tan unless $tan > 100;
      my $output="eje.g";
      die "Can't open $output" unless open(OUTPUT, "> $output");
      print OUTPUT <<"AQUI";
set term mp color solid latex magnification 1
set out 'fig.mp'
#
set size square
set border 
#lw 0 lt 0
unset xtics
unset ytics
set xrange [-1:1]
set yrange [-1:1]
unset key
m='$m'
y(x,m)=m*x
p y(x,m) w l lt 2 lw 8
AQUI
      #
      # gnuplot generates the figure
      #
      system "$exe_mpplotlin eje.g 1 2 >log";
      system "convert eje.pdf eje.png";
      my $ejesize=`file eje.png | awk -Fx '{print \$1}' | awk -F, '{print \$2}'`;
      my $xeje=-($ejesize-27);
      system "rm log*";
      # plot with angle-vs-eV and ucell
      my $output2="batman.tex";
      die "Can't open $output2" unless open(OUTPUT2, "> $output2");
      print OUTPUT2 <<"HASTAQUEMECANSE";
\\documentclass[preprint,12pt]{revtex4}
\\usepackage[usenames,dvipsnames]{xcolor}
\\usepackage[spanish,english]{babel}
\\usepackage[utf8]{inputenc}
\\usepackage{graphicx}
\\usepackage{grffile}
\\input{$defi}
\\pagestyle{empty}
\\begin{document}
\\begin{center}
\\begin{picture}(5,20)
%\\put(-180,-120){\$\\alpha=$angulo\$}%
\\put(-180,-350){\\includegraphics[scale=$scale]{ucell/$fig}}%
\\put(-50,-380){\\includegraphics[scale=.8]{plots/$plot}}%
\\put(-139,-309){\\includegraphics[scale=.2]{eje}}%
\\end{picture}
\\end{center}
\\end{document}
HASTAQUEMECANSE
      system "pdflatex batman > log";
      system "pdfcrop batman.pdf > log";
      #my $pcell="cell-rt-$df-nm-$whole\_t$theta";
      my $pcell="cell-rt-$df-nm-$whole";
      system "mv batman-crop.pdf plots/$pcell-$n.pdf";
      system "rm fig.mpx eje* batman* errorPLOTLINE log";
    } # while for angles
    # file for anima.tex 
    printf "\n\tDoing the movie\n";
    my $output1="anima.tex";
    my $mcell="cell-rt-$df-nm-$whole";
    die "Can't open $output1" unless open(OUTPUT1, "> $output1");
    print OUTPUT1 <<"HASTAQUEMECANSE";
\\documentclass[dvipsnames]{beamer}
\\usepackage{animate}
\\begin{document}
\\begin{center}
\\strut
\\vfill
\\animategraphics[controls,scale=.7,palindrome]{6}{plots/$mcell-}{1}{$n}
\\vfill
\\strut
\\end{center}
\\end{document}
HASTAQUEMECANSE
    system "pdflatex anima.tex > log";
    system "pdflatex anima.tex > log";
    system "mv anima.pdf movies/m-rt-$df-nm-$whole.pdf";
    print  "\n\tMovie: movies/m-rt-$df-nm-nc-$nc-$whole.pdf\n";
    printf "\n";
    #    system "rm  lrem*" if ! $keep;
    system "rm anima* log*";
    ####
    #die;
  } # while for input files
__END__
