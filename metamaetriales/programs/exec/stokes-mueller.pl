#!/usr/bin/env perl

# calculates Degree of Polarization 
# across a film made of a metamaterial 
# It does so using the Jones Matrix to construct the Mueller Matrix
# from where it obtains the Stokes vector for a given incident Stokes vector
# The Film thickness, and the indices of refraction for the incoming and outgoing media are
# irrelevant, so we fix them to 100nm, 1 and 1, to comply with tSalb.pl, where the
# required principal values vectors and reflection and transmission coefficients are calculated,
# and then used to calculate the outgoing Stokes vector in stokes.f90
#
use strict;
use Getopt::Long;
use File::Basename;
use constant pi=>4*atan2(1,1);
#path for definitions.tex
#read from PWD/.defi
my $defi=`awk '{print \$1}' .defi`;
$defi=~s/\s+//g;
#my $defi="/Users/bms/util/definitions.tex";
#
my $ruta=`awk '{print \$1}' .ruta`;
$ruta=~s/\s+//g;
#my $ruta="/Users/bms/research/metamaterials/haydock/fields/programs/exec";
# executables
my $exe_mpplotlin="$ruta/utilerias/mpplotlin.sh";
my $exe_rt="$ruta/tSlab.pl";
#
# defines the variables
#
# n->incident medium
my $ni;
# n->transmitted medium
my $nt;
my $tag;
my $df;
my $n;
#
# gets the options from the command line
#
GetOptions(
    "tag=s" => \$tag,
    "df=f" => \$df,
    "ni=f" => \$ni,	   
    "nt=f" => \$nt,	   
	  );
#
# screen instructions
#
die <<"FIN"

cc=[A,S]# ; ls meps/eps-figure*\$cc*-dat | sort -t[A,S] -n -k | stokes-mueller.pl --tag=\$cc --ni=i-index --nt=t-index --df=thickness

                  s=>string

    Calculates outgoing Stokes vector

    Give the Scale or Angle values as:
    A# or S# where #=numerical value
    In sort pick A if cc=S# or S if cc=A#
    This must agree with what you are 
    using in ls cases/figure*.png 
    Example: does all the S for a fixed A=0.00 for figure=cross

cc=A0.00 ; ls meps/eps-cross*\$cc*-dat-original |sort -tS -n -k 2 | ~/research/metamaterials/haydock/fields/programs/exec/stokes-mueller.pl --tag=\$cc 

FIN
  unless defined $tag and defined $df and defined $ni and defined $nt;
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
  # generates R and T that we Don't need
  # and the parafernalia to generate 
  # the outgoing Stokes vector that we need
  my $plot="nt-$nt-$df-nm-$whole";
  my $corre="$exe_rt --if=$caso --of=$plot --od=stokes --theta=0 --na=1 --nc=$nt --df=$df";
  #printf "\t$corre\n";
  system $corre;
  my $nw=`wc -l $caso| awk '{print \$1}'`;
  my $f1='fort.1';
  my $OUTFILE;
  open $OUTFILE, '>>', $f1;
  print { $OUTFILE } "$nw";
  close $OUTFILE;
  my $f2="cp stokes/m-$plot fort.2";
  system $f2;
  my $borra="rm stokes/nt-*";
  system $borra;
  # runs stokes.f90
  my $stokes='/Users/bms/research/metamaterials/haydock/fields/programs/exec/rstokes';
  system $stokes;
  my $chin="mv fort.3 stokes/s-nt-$nt-$df-nm-$whole";
  system $chin; 
  my $borra="rm fort.*";
  system $borra;
  printf "\tOutput: stokes/s-nt-$nt-$df-nm-$whole\n\n";
  #die;
} #files
__END__
