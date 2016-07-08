#!/usr/bin/env perl
############################################################################
# calculates Haydock coefficients and basis for a 2D superlatice
# in the long wavelength approx
# using inkscape for B(r)
# where one defines the unit cell size and the size and shape of B(r)
# in file->Document Properties chose the number of Nx and Ny in px (pixels)
# (above also determines Lx and Ly and the relative size of the inclusion)
# then save as file.png 
# White is matrix and black is inclusion.
# Some times is necessary to convert into Black and White. Use
# convert file.png -monochrome fileBW.png
############################################################################
#BEGIN {
#push @INC,
#"/opt/local/var/macports/software/p5-pdl/2.4.3_0/opt/local/lib/perl5/vendor_perl/5.8.9/darwin-2level";
#}

use warnings;
use strict;
use Getopt::Long;
use PDL;
use PDL::NiceSlice;
use PDL::FFTW;
use PDL::IO::Pic;
use PDL::IO::Dumper;#fdump
#use Storable;#store
#use PDL::IO::Storable;#store
use File::Basename;
use PDL::Complex;
use PDL::IO::Misc;

use constant PI=>4*atan2(1,1);
my $bNM12min=1e-7; #Haydocks bN^2 is small if smaller than this

my ($Nx, $Ny); #max indices for wavevectors
my $Nh; #Max. number of Haydocks coefficients
my ($dx, $dy); #period of structure
my $ifn; #file name 
my $od; #output directory
my $axes; #crystal or principal
my $ang1; #angle1 of polarization-ellipse for PV 1 
my $ang2; #angle2 of polarization-ellipse for PV 2
my $ev;#energy, optional
my $epsa;#epsa=R+Ii only fore axes=prinxipal
my $epsb;#epsb=R+Ii only fore axes=prinxipal
my $eab; #imaginary part of the angle of Principal axes w.r.t Crystal axes
GetOptions(
    "Nh=i" => \$Nh, 
    "if=s" => \$ifn,
    "od=s" => \$od,
    "axes=s" => \$axes,
    "ang1=f" => \$ang1,
    "ang2=f" => \$ang2,
    "ev=s" => \$ev,
    "epsa=s" => \$epsa,
    "epsb=s" => \$epsb,
    "eab=s" => \$eab,
    );

die <<"FIN"
  \n./haydock2DNRBase.pl --Nh=i --if=inputFilename --od=outputDirectory --axes=s --ang=f --epsa=R+Ii --epsb=R+Ii [--ev=f] [--eab=f]

    Calculates Haydock coefficients for a 2D rectangular lattice
    of inclusions drawn with Inkscape 

    --Nh=i        maximum number of Haydock coefficients
    --if=filename input file (default png extension) with the unit cell 
    --od=path     output directory. 
                  Note: The output filenames are built from the input
                  image name by appending the number of desired coefficients 
                  and the extension .pld. 
  --axes=s        crystal=>Crystal axes or principal=>Principal axes
   --ang=f        angle of polarization-elipse PV (1,2)
                  Must be given only if --axes=principal
--eps[a/b]=s      eps[a/b]=R+Ii
                  Must be given only if --axes=principal
    --ev=f        Energy -> Optional
   --eab=f        Imaginary part of the Principal axis angle 

FIN
unless defined $Nh and defined $ifn and defined $od and defined $axes;
#
# checks correct spelling
if ("$axes"ne"crystal" and "$axes"ne"principal") {
die "\n\t--axes must be crystal or principal\n\n"
}
# checks that if --axes=principal the angle is given
my $angr;
if ("$axes"eq"principal") {
  if ("$ev"eq"ave"){
#    printf "\tDoing average theta\n";
  }
  else
    {
      die "\n\tprincipal axes: give a value for --ang(1,2) --eps[a/b]\n\n" unless defined $ang1 and defined $ang2 and defined $epsa and defined $epsb;
    }
#from degrees to radians
$angr=($ang1*PI/180);
}

#normalized directions to calculate
my %dirs;
#for crystal axes 
%dirs= ( xx=>pdl(1,0), xy=>pdl(1,1), yy=>pdl(0,1) ) unless "$axes"eq"principal";
#for principal axes 
%dirs= ( xp=>pdl(cos($angr),sin($angr)), yp=>pdl(-sin($angr),cos($angr)) ) unless "$axes"eq"crystal";

#
foreach(keys %dirs){
    $dirs{$_}=$dirs{$_}->norm; 
}
my ($base, $dir, $ext)=fileparse($ifn, ".png");
$ext=".png" unless defined $ext;
my $input="$dir$base$ext";
die "File not readable: $input" unless -r $input;

# changes the figure to B&W
system "convert $input -monochrome $dir${base}BW$ext";
$input="$dir${base}BW$ext";
my $B=rpic $input; # changes png file into 0's and 1's
$B = $B==0; #white is matrix and black is inclusion.
#
# TEMPORAL
# $B=zeroes(201,201)->rvals<=95;
# imagrgb[$B];
#
my $Nel=pdl(($dx,$dy)=$B->dims);
my $d=$Nel; #assume distance is proportional to number of pixels.
die "The size of the image must be odd" unless all $Nel%2==1;
my $N=($Nel-1)/2;
($Nx, $Ny)=$N->list;
# discreet position vectors array, indexed by cartesian coordinate
# (0=x, 1=y) and by element indices nx, ny. Center is at $N.
my $f=$B->sum/$Nel->prodover; #filling fraction.
my $ff=sprintf "%.3f", $f;
#filter large wavevectors (outside some disk)
#Filter to keep only wavevectors within a disk.
my $filter=zeroes($Nel->at(0), $Nel->at(1))->rvals<=.5*$Nel->at(0);
$filter=$filter->rotate($Nx)->transpose->rotate($Ny)->transpose;
#
my $r=cat((zeroes($Nel->at(0))->xvals-$N->at(0))->(,*$Nel((1))),
    (zeroes($Nel->at(1))->xvals-$N->at(1))->(*$Nel((0))))
    ->mv(2,0);
$r *= $d/($Nel); #add units.
# reciprocal space, indexed by cartesian coordinate and reciprocal
# indices.
my $g=cat((sequence( $Nel->at(0))-$N->at(0))->(,*$Nel((1))),
	  (sequence($Nel->at(1))-$N->at(1))->(*$Nel((0))))
    ->mv(2,0);
# Notice: $Nel((0)) is not equivalente to $Nel->at(0) above, as zeroes
# acts differently on perl scalars than on pdl's
$g *= (2*PI)/$d; # add reciprocal units.
my $gnorm=$g->norm; # array of normalized wavevectors
# Note: multiply by sinc(G Delta r) before normalizing?
# Prepare kronecker's delta, for initial state 
my $deltaG0=zeroes($Nel->at(0),$Nel->at(1));  
$deltaG0($N->at(0), $N->at(1)).=1;
# output file name
my $output;
my $angle1;
my $angle2;
my $fev;
$output="${od}${base}\_crystal.pld" unless "$axes"eq"principal"; #output filename for crystal
if ("$axes"eq"principal") {
  $angle1=sprintf "%.2f", $ang1;
  $angle2=sprintf "%.2f", $ang2;
  $fev=sprintf "%.5f", $ev unless "$ev"eq"ave";
  $fev=sprintf "%.5f", $ev unless "$ev"ne"ave";
  if ("$ev"eq"ave"){
    $output="${od}${base}\_principal\_$angle1\_$fev.pld" unless "$axes"eq"crystal"; 
  }
  else{
    $output="${od}${base}\_principal\_$angle1,$angle2,$eab\_vsw\_W$fev\_epsa_$epsa-epsb_$epsb.pld" unless "$axes"eq"crystal"; 
  }
}
#printf "\t$output\n";
#die;
# defines states and Haydock's coefficients
my %states;
my %bN2;
my %aN;

# iterate over desired directions
foreach my $dir (sort {$a cmp $b} keys %dirs){
    my @states;
    my @bN2;
    my @aN;
    my $q = $dirs{$dir};
    printf "\tRunning for $dir\n";

    $gnorm(,$N(0),$N(1)).=$q->norm ; #establish direction of vec 0
    # Intialize iteration
    # State N. Rotate so indices become positive. Facilitates Fourier
    # transforms.
     my $vecN=cat(
	$deltaG0->rotate(-$Nx)->transpose->rotate(-$Ny)->transpose,
		 pdl(0))->mv(2,0); # add imaginary part as first index;  
    my $vecNm1=pdl 0;
    my $bN=0;
    my $bN2=0;
    my $niter=0;
    # rotated as above. First get cartesian index out of the way, then
    # rotate each indexand then restore order of indices
    my $gnormrot=$gnorm->mv(0,2)->
	rotate(-$Nx)->transpose->rotate(-$Ny)->transpose->mv(2,0);
    my $Brot=$B->rotate(-$Nx)->transpose->rotate(-$Ny)->transpose;
    while($niter++<$Nh){
	push @states, $vecN;
	# the indices of gvecN are realorcomplex, cartesian, nx,ny
	my $gvecN=Cscale($vecN,$gnormrot->mv(0,2))->mv(3,1);
	my @tmp;
	foreach my $comp (0,1){ #for each cartesian component
	    #take 2D fourier transform over nx, ny
	    my $tmp=ifftw($gvecN->(,(($comp)),)); 
	    $tmp=Cscale($tmp,$Brot); #multiply by characteriztic func 
	    #fourier transform back, normalize and store
	    $tmp[$comp]=fftw($tmp)/($Nel->prodover);
	}
	my $vecNM1 = cat($tmp[0], $tmp[1]); # RorC, nx, ny, cart
	# scalar product with hat G, the result is indexed by RorI,
	# nx, ny
	$vecNM1=Cscale($vecNM1,$gnormrot->mv(0,2))->mv(3,0)->sumover;
        # filter
        # $vecNM1=Cscale($vecNM1, $filter);
	# project, assume real
	my $aN=(Cmul($vecN->Cconj, $vecNM1))->((0))->sum;
	my $bNM12=Cmod2($vecNM1)->sum - $aN**2 - $bN2;
	#bNM12 shouldn't be negative. Eliminate numerical error 
	die "\$bNM12=$bNM12 is negative! dir=$dir, iter=$niter" if $bNM12 < -$bNM12min;
	$bNM12=pdl(0) if $bNM12<0; 
	my $bNM1=sqrt($bNM12);
	# save results
	push @aN, $aN;
	push @bN2, $bNM12;
	# test for early retirement
	last if abs($bNM12) < $bNM12min;
	# Orthogonormalize new state
	$vecNM1=$vecNM1-$aN*$vecN-$bN*$vecNm1;
	$vecNM1=Cscale($vecNM1,1/$bNM1);
	#iterate	
	$vecNm1=$vecN;
	$vecN=$vecNM1;
	$bN2=$bNM12;
	$bN=$bNM1;
      }
    #print OUTPUT "Direccion $dir\n";
    unshift @bN2, 0;
    # copy data to associative array
    $states{$dir}=[@states];
    $bN2{$dir}=[@bN2];
    $aN{$dir} = [@aN];
}
printf "\n";
printf "\tSaving in $output as structured pld file\n";
my $ti=time;
my $hash;
if ("$axes"eq"crystal"){
  printf "\tBut only a's and b's for $axes axes";
  fdump({dirs=>\%dirs, bN2=>\%bN2, aN=>\%aN}, $output);
#  $hash={dirs=>\%dirs, bN2=>\%bN2, aN=>\%aN};
#  store $hash,$output;
}
if ("$axes"eq"principal"){
  fdump({dirs=>\%dirs, states=>\%states, bN2=>\%bN2, aN=>\%aN}, $output);
#  $hash={dirs=>\%dirs, states=>\%states, bN2=>\%bN2, aN=>\%aN};
#  store $hash,$output;
}
my $tf=sprintf "%.2f", ((time-$ti)/60);
printf "\n";
printf "\tDone in $tf minutes!\n";
system "rm $input";
