#!/usr/bin/env perl
#######################
# Handy
# mkdir cases ucell hc res meps plots movies arrows rt
# rm -rf hc res meps plots movies arrows
#######################
use strict;
use warnings;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);
use File::Basename;
use Pod::Usage;
use Time::HiRes qw(time);
# initial time
my $t0 = time;
#
####### PUT THE PATH #################################
# path where the programs are located in your computer
#my $ruta="~/txt/cache/13/berny20130827/programs";
#my $ruta="/home/bms/programsWLM";
my $ruta="/Users/bms/research/metamaterials/haydock/fields/programs/exec";
######################################################
# path for definitions.tex
my $defi="$ruta/utilerias/definitions";
# put in:
# PWD/.ruta so they are found.
die "Can't open .ruta" unless open(OUTPUT3, "> .ruta");
print OUTPUT3 "$ruta";
# PWD/.defi so it is found.
die "Can't open .defi" unless open(OUTPUT4, "> .defi");
print OUTPUT4 "$defi";
my $exe_whole="$ruta/whole-enchilada.pl"; 
#
# Options
my $Nh;#Haydock's coefficients
my $epsa;#material or value R-I
my $epsb;#material or value R-I
my $nem;#ave=>average or vsw=>vs energy
my $case;#unit cell
my $fixedangle;# fixed polarization angle
my $cual;# ronly=>only reflection all=>reflection and fields
#
GetOptions(
	   "Nh=i" => \$Nh,
	   "epsa=s" => \$epsa,
	   "epsb=s" => \$epsb,
	   "nem=s" => \$nem,
	   "case=s" => \$case,
	   "cual=s" => \$cual,
	   "fixedangle=f" => \$fixedangle,
	  );
#
# screen instructions
#
die <<"FIN"

 the-whole-enchilada.pl --Nh=i --epsa=s --epsb=s --nem=s --case=cases/ --cual=s [--fixedangle=f]

             s=>string f=>real i=integer 

    Generate plots with arrows following the Reflectance spectrum

    --Nh=i            Haydock's coefficients            
    --epsa=s          material or value R-I
    --epsb=s          material or value R-I
    --nem=s           ave=>average, vsw=>vs energy or both=>average and vsw
    --case=cases/s    unit cell(s), use * to run several cells
    --cual=s          ronly=>only reflection all=>reflection and fields
    --fixedangle=f    [Optional] Fixed Polarization Angle 

FIN
  unless defined $Nh and defined $epsa and defined $epsb and defined $nem and defined $case and defined $cual;

&myline;
printf "\tOnly Running for Reflection\n" unless ("$cual"eq"all");
&myline unless ("$cual"eq"all");#only reflection
printf "\tRuning for $case\n";
printf "\tStart with Crystal axes\n";
system "ls $case | $exe_whole --Nh=$Nh --epsa=$epsa --epsb=$epsb --axes=crystal --fields=yes --cual=$cual";
printf "\tReflection is Done!\n" unless ("$cual"eq"all");
printf "\tproceed with plot-angles.pl\n" unless ("$cual"eq"all");
&myline unless ("$cual"eq"all");#only reflection
die unless ("$cual"eq"all");#only reflection
if ("$nem"eq"ave") {
  &myline;
  if(!defined $fixedangle){
    printf "\tFollow with Principal average axes\n";
    system "ls $case | $exe_whole --Nh=$Nh --epsa=$epsa --epsb=$epsb --axes=principal --fields=yes --nem=$nem --cual=$cual";
  }
  if(defined $fixedangle){
    printf "\tFollow with fixed polarization axes\n";
    system "ls $case | $exe_whole --Nh=$Nh --epsa=$epsa --epsb=$epsb --axes=principal --fields=yes --nem=$nem --fixedangle=$fixedangle --cual=$cual";
  }
}
if ("$nem"eq"vsw"){
  &myline;
  printf "\tFollow with Principal for every angle\n";
  system "ls $case | $exe_whole --Nh=$Nh --epsa=$epsa --epsb=$epsb --axes=principal --fields=yes --nem=$nem --cual=$cual";
}
if ("$nem"eq"both"){
  &myline;
  printf "\tFollow with Principal for both average and every angle\n";
  system "ls $case | $exe_whole --Nh=$Nh --epsa=$epsa --epsb=$epsb --axes=principal --fields=yes --nem=ave --cual=$cual";
  system "ls $case | $exe_whole --Nh=$Nh --epsa=$epsa --epsb=$epsb --axes=principal --fields=yes --nem=vsw --cual=$cual";
}
# final time
my $elapsed = time - $t0;
$elapsed=($elapsed/60);
$elapsed=sprintf "%.2f", $elapsed;
&myline;
printf "\tTotal time $elapsed minutes\n";
&myline;
########
sub myline {
  printf "\t*************************\n";}

__END__

