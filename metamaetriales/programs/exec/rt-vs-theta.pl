#!/usr/bin/env perl

# calculates the normal incidence reflection and transmission coefficients
# across a film made of a metamaterial 
# as a function of the angle between the incoming electric field and the x-axis
# of the metamaterial

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

cc=[A,S]# ; ls meps/eps-figure*\$cc*-dat | sort -t[A,S] -n -k | rt-vs-theta.pl --tag=\$cc --df=thickness --ni=incident --nt=transmitted 

                  s=>string

    Calculates R&T vs theta 

    Give the Scale or Angle values as:
    A# or S# where #=numerical value
    In sort pick A if cc=S# or S if cc=A#
    This must agree with what you are 
    using in ls cases/figure*.png 
    Example: does all the S for a fixed A=0.00 for figure=cross

cc=A0.00 ; ls meps/eps-cross*\$cc*-dat-original |sort -tS -n -k 2 | ~/research/metamaterials/haydock/fields/programs/exec/rt-vs-theta.pl --tag=\$cc --df=\$df --ni=1 --nt=1.4

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
  # generates R and T
  # loop over theta
  # 0->180
  my $thetas="5"; #steps
  my $theta="-5";  #initial
  my $thetaf="180";#final
  # 130->150
  #my $thetas="1"; #steps
  #my $theta="29";  #initial
  #my $thetaf="70";#final
  # 40->50
  #my $thetas="1"; #steps
  #my $theta="40";  #initial
  #my $thetaf="50";#final
  #
  $thetaf=$thetaf-$thetas;
  $n=0;
  while ($theta <= $thetaf) {
    $n=($n+1);
    $theta=$theta+$thetas;
    printf "\tfor theta=$theta and nt=$nt\n";
    my $plot="rt-nt-$nt-$df-nm-$whole\_t$theta";
    my $corre="$exe_rt --if=$caso --of=$plot --od=rt --theta=$theta --na=$ni --nc=$nt --df=$df";
    #printf "\t$corre\n";
    system $corre;
  } #angles
} #files
__END__
