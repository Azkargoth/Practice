#!/usr/bin/env perl
#######################
# usage
# go to the directory where the figures.png are
# chose a set with ls, i.e.
# ls elipse*s1.20*
# run with
# ls  path1/elipse*s1.20* | path2/fields/programs/corre-fields.pl (follow instructions)
#######################

use strict;
use Pod::Usage;
use Getopt::Long;
use File::Basename;
use Cwd;
#
#programas a correr
#path where the programs are located in your computer
#read from PWD/.ruta
my $ruta=`awk '{print \$1}' .ruta`;
$ruta=~s/\s+//g;
my $haydock="$ruta/haydock2DNRFields.pl";
# otras variables# reads input
# Options
my $Nh; # number of Haydock coefficients
my $ifn; #file name 
my $od; #output directory
my $epsa; #dielec. func of matrix
my $epsb; #dielec. func of particle
my $helpflag; #help
#
pod2usage unless GetOptions(
    "Nh=i" => \$Nh, 
    "od=s" => \$od,
    "epsa=s" => \$epsa,
    "epsb=s" => \$epsb,
    "help|?"=>\$helpflag,
    ) and !$helpflag and defined $Nh and defined $od 
and defined $epsa and defined $epsb; 

while(<>){
  chomp(my $caso=$_);
  my ($base, $directory, $extension)=fileparse($caso, ".pld");
  $caso="$directory$base$extension";
  # get epsa and epsb (cumbersome)
  my ($void,$auxa)=split('epsa_',$base,2);
  my ($auxa,$void)=split('-epsb_',$auxa,2);
  my ($nepsar,$nepsai)=split("\\+i\\*",$auxa,2);
  my ($void,$auxb)=split('epsb_',$base,2);
  my ($nepsbr,$nepsbi)=split("\\+i\\*",$auxb,2);
  $nepsar=sprintf "%.3f",$nepsar;
  $nepsai=sprintf "%.3f",$nepsai;
  $nepsbr=sprintf "%.3f",$nepsbr;
  $nepsbi=sprintf "%.3f",$nepsbi;
  my $namen="res/e-$base\_Nh\_$Nh\_epsa\_$nepsar-$nepsai\_epsb_$nepsbr-$nepsbi\_dir\_xp-dat";
  if (-e $namen){
    &myline;
    print "\tFields and Polarizations Exists no need to calculate again\n";
    &myline;
    #    die;
  }
  else{
    my ($n1,$n12,$n21,$n2,$n11)=split('_',$base,5);
    my $angs;
    if ("$n11"eq"crystal"){
      printf "\n\tCrystal axes: Only using one set of HC";
      $angs="void";#any string will do
    }
    if ("$n11"ne"crystal"){
      my ($n1,$n21,$n2)=split('_',$n11,3);
      if ("$n2"eq"ave"){
	printf "\n\tUsing average theta: Only using one set of HC";
	$angs="ave";
      }
      if ("$n2"ne"ave"){
	printf "\n\tRunning for every theta: Using each set of HC\n";
	$angs="all";
      }
    }
    #    
    print "\n";
    print "\tRunning Fields for $caso\n";
    print "\n";
    system "$haydock --Nh $Nh --if $caso --od $od --epsa $epsa --epsb $epsb --angs $angs";
  }
}    
printf "\tDone!\n\n";
sub myline {
  printf "\t*************************\n";}

    __END__

=head1 SYNOPSIS

ls path/files*.pld | path/corre-fields.pl --Nh=i --od=outDir --epsa= dielFuncA  --epsb= dielFuncB

    Calculates the Electric field of a binary 2D metamaterial
    using the Haydock coefficients and States in pld structured form
 
    files*.pld    path/input-files (pld) of unit cells
                  The * is to group the pld files 

    --Nh=i        maximum number of Haydock coefficients
    --od=path     output directory. 
                  Note: The output filenames are built from the input
                  image name by appending the number of desired coefficients 
                  and the extension .dat
     --eps[a/b]   a=>matrix, b=>inclusion
                  dielectric function value (R+i*I) or file 
                  (R,I) real values; scientific notation accepted 
                  Warning: [+/-]i* must not be separated

=cut
