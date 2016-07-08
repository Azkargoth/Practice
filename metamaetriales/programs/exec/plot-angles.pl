#!/usr/bin/env perl

# plots the electric field intensity and its vector field 

use strict;
use Getopt::Long;
use File::Basename;
#path for definitions.tex
#read from PWD/.defi
my $defi=`awk '{print \$1}' .defi`;
$defi=~s/\s+//g;
#
my $ruta=`awk '{print \$1}' .ruta`;
$ruta=~s/\s+//g;
# executables
my $exe_mpplotlin="$ruta/utilerias/mpplotlin.sh";
#
# defines the variables
#
my ($tag);
#
# gets the options from the command line
#
GetOptions(
    "tag=s" => \$tag,
    );
#
# screen instructions
#
die <<"FIN"

cc=[A,S]# ; ls meps/eps-figure*\$cc*-dat | sort -t[A,S] -n -k 2 | ../programs/plot-angles.pl --tag=\$cc

                  s=>string

    Generate PV angle plots with the corresponding unit cell

    Give the Scale or Angle values as:
    S# or A# where #=numerical value
    In sort pick A if cc=S# or S if cc=A#
    This must agree with what you are 
    using in ls cases/figure*.png 
    Example: does all the Angles for a fixed S=1.1 for figure=cross

cc=S1.1 ; ls meps/eps-cross_A*\$cc*-dat | sort -tA -n -k 2 | ../programs/exec/plot-angles.pl --tag=\$cc

FIN
unless  defined $tag;
#
# the programs begins here
#
my $caso;

my $n=0;
  while(<>) {
    chomp($caso=$_);
    $n=($n+1);
    my ($base, $dir, $ext)=fileparse($caso, "-dat");
    my ($void,$data)=split('eps-',$base,2);
    my ($fig)=split('_f',$data,2);
    #gets the angle
    ($void,$data)=split('_A',$fig,2);
    my ($angulo)=split('_S',$data,2);
    printf "\t$fig $n\n";
    # size of the tile of unit cells
    my $fsize=`file ucell/$fig.png | awk -Fx '{print \$1}' | awk -F, '{print \$2}'`;
    # scale the size
    my $scale=(603./$fsize)*.3;
#    printf "\t$scale\n";
#    die;
    # plot with angles vs photon-enrgy
    my $output="grafica.g";
    die "Can't open $output" unless open(OUTPUT, "> $output");
    print OUTPUT <<"HASTAQUEMECANSE";
set term mp color solid latex magnification 1
set out 'fig.mp'
file='$caso'
set multiplot
set origin 0,1
set size 1,.8
set ylabel '\\Large \$R\$'
set key right spacing 1.2
set yrange[0:1]
p file u "w":"nir1"  w l t '\$R_1\$',\\
  file u "w":"nir2"  w l t '\$R_2\$'
set origin 0,.2
set size 1.1,.8
set ylabel '\\Large \$\\eta\$ (third-flattening)'
set y2label '\\Large \$\\alpha_a(^\\circ)\$'
set xlabel '\\Large photon-energy (eV)'
#unset key
set auto
#set yrange[-100:100]
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# Obsolete and wrong, kept as non-harming DNA
# plots teta(1,2) imaginary part
#p file u "w":"tet1r"  w p t 'Re(\$\\theta_1\$)',\\
#  file u "w":"tet2r"  w p t 'Re(\$\\theta_2\$)',\\
#  file u "w":"tet1i"  w p t 'Im(\$\\theta_1\$)',\\
#  file u "w":"tet2i"  w p t 'Im(\$\\theta_2\$)'
# plots third flattening= (a(i)-b(i))/(a(i)+b(i)) 
# &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
f(x,y)=(x-y)/(x+y)
set y2tics
set ytics nomirror
set yrange [0:1.1] 
p file u "w":(column("ht1")==2? f(column("a1"),column("b1")):1/0) w l lw 3 lt 1 t '\$\\eta_1:\\circlearrowleft\$',\\
file u "w":(column("ht1")==1? f(column("a1"),column("b1")):1/0) w p pt 1 lt 1 t '\$\\eta_1:\\circlearrowright\$',\\
 file u "w":(column("ht2")==2? f(column("a2"),column("b2")):1/0) w l lw 3 lt 2 t '\$\\eta_2:\\circlearrowleft\$',\\
 file u "w":(column("ht2")==1? f(column("a2"),column("b2")):1/0) w p pt 1 lt 2 t '\$\\eta_2:\\circlearrowright\$',\\
  file u "w":"aa1"  w l lt 1 t '\$\\alpha_a(1)\$' axis x1y2,\\
  file u "w":"aa2"  w l lt 2 t '\$\\alpha_a(2)\$' axis x1y2
#  file u "w":(column("a1")) w lp t '\$a_1\$)' axis x1y2,\\
#  file u "w":(column("a2")) w lp t '\$a_2\$)' axis x1y2,\\
#  file u "w":(column("b1")) w lp t '\$b_1\$)' axis x1y2,\\
#  file u "w":(column("b2")) w lp t '\$b_2\$)' axis x1y2
HASTAQUEMECANSE
    #
    # gnuplot generates the figure
    #
    system "$exe_mpplotlin grafica 1 2 >log";
    system "cp grafica.pdf plots/$fig.pdf";
    system "rm grafica.*";
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
\\put(-180,-120){\$\\alpha=$angulo\$}%
\\put(-250,-330){\\includegraphics[scale=$scale]{ucell/$fig}}%
\\put(-50,-380){\\includegraphics[scale=.8]{plots/$fig}}%
\\end{picture}
\\end{center}
\\end{document}
HASTAQUEMECANSE
    system "pdflatex batman > log";
    system "pdfcrop batman.pdf > log";
    system "mv batman-crop.pdf plots/lrem-$n.pdf";
#    system "cp lrem-$n.pdf keep/$ep-lrem-$n.pdf" if $keep;
#    system "rm rem*";
  } # while
    # file for anima.tex 
    printf "\n\tDoing the movie\n";
    my $output1="anima.tex";
    die "Can't open $output1" unless open(OUTPUT1, "> $output1");
    print OUTPUT1 <<"HASTAQUEMECANSE";
\\documentclass[dvipsnames]{beamer}
\\usepackage{animate}
\\begin{document}
\\begin{center}
\\strut
\\vfill
\\animategraphics[controls,scale=.5,palindrome]{6}{plots/lrem-}{1}{$n}
\\vfill
\\strut
\\end{center}
\\end{document}
HASTAQUEMECANSE
    system "pdflatex anima.tex > log";
    system "pdflatex anima.tex > log";
    system "mv anima.pdf movies/a-m-$tag.pdf";
    print  "\n\tMovie: movies/a-m-$tag.pdf\n";
    printf "\n";
#    system "rm  lrem*" if ! $keep;
system "rm anima* log*";
    ####
system "rm error* batman* ";
__END__
