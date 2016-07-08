#!/usr/bin/env perl
#######################
# usage
# chose a set with ls, i.e.
# ls elipse*s1.40*
# run with
# if the filling fraction (equivalent to the scale factor S) is fixed
# a proper numerical sorting of the angles is needed, thus use, i.e.:
#ls res/e-elipseBW_*S0.999_*12*x*-dat | sort -tA -n -k 2|  ../programs/corre-plots.pl --Nx=201 --Ny=201 --od=res/ --cell=2
# if the angle is fixed, i.e.
#ls res/e-elipseBW_A10.00*12*x*-dat | sort -tS -n -k 2|  ../programs/corre-plots.pl --Nx=201 --Ny=201 --od=res/ --cell=2
# change the file* specification as needed, to single out the required cases 
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
my $exec="$ruta/plots.pl";
## reads input
# Options
my $Nx; # x-pixels
my $Ny; # y-pixels
my $ifn; #file name 
my $od; #output directory
my $cell; #1=>1x1 or 2=>2x2
my $helpflag; #help
my $sino; #yes=>plots no=>no plots
my $zmax;
my $zmin;
#
pod2usage unless GetOptions(
    "Nx=i" => \$Nx, 
    "Ny=i" => \$Ny, 
    "od=s" => \$od,
    "cell=i" => \$cell,
    "zmax=f" => \$zmax,
    "zmin=f" => \$zmin,
    "help|?"=>\$helpflag,
    ) and !$helpflag and defined $Nx and defined $Ny 
and defined $od and defined $cell and defined $zmax and defined $zmin; 

my $nname;
my $cont=0;
my $NL=0;
my @files;
while(<>){
    chomp;
    push @files, $_;
    $NL=($NL+1);
}

foreach my $case (@files){
  $cont=($cont + 1);
  my ($base, $directory, $extension)=fileparse($case, ".png");
  $case="$directory$base";
  my ($duu,$dir)=split(_dir_,$base,2);
  ($dir)=split('-',$dir,2);
  print "\tRunning plot $cont of $NL for $dir\n";
  # name for movie. WARNING so far works for epsb=file 
  my ($ini,$fin)=($1,$2) if $base=~/^e-(.*)_W(.*)-dat/; 
  my ($finn)=($2) if $fin=~/(.*)_epsb(.*)/; 
  $nname="$ini\_epsb$finn";
  system "$exec --Nx $Nx --Ny $Ny --idf $case --od $od --cell $cell --tag $cont --zmin $zmin --zmax $zmax";
}

sub max {
    my $a=shift;
    my $b=shift;
    return $a unless defined $b;
    return $b unless defined $a;
    return $a if $a>$b;
    return $b;
}
    
sub min {
    my $a=shift;
    my $b=shift;
    return $a unless defined $b;
    return $b unless defined $a;
    return $a if $a<$b;
    return $b;
}

__END__

=head1 SYNOPSIS

ls path/e-*-dat | sort -t[A,S,W] -n -k 2 | path/corre-plots.pl --Nx=i --Ny=i --od=s --cell=i
  
                  sort A(angles), S(scale) or W(energy) 
                  i=>integer s=>string

 Plots Electric Field Intensity and vector field for several cases
    
 e-*-dat are the files with the electric fields for x and y external E-field

    --N(x,y)=i        pixels along (x,y)
    --od=path         output directory. 
    --cell=i          1=>1x1, 2=>2x2

=cut
