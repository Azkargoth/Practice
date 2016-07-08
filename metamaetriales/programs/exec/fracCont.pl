#!/usr/bin/env perl
######
use strict;
use warnings;
use PDL;
use PDL::Complex;
use Getopt::Long;
use PDL::IO::Dumper;#frestore
#use Storable;#store
#use PDL::IO::Storable;#freeze
use PDL::NiceSlice;
use Scalar::Util qw(looks_like_number);
use File::Basename;
#use Math::Complex;

use constant SMALL=>1e-10;
use constant PI=>4*atan2(1,1);

my $epsa; # filenames for eps a, eps b and haydock's coeff.
my $epsb;
my $fhaydock; # filename for Haydock coeffs.
my $od; #output directory
my ($nepsa, $nepsb); # flag numeric (vs file) epsilons
my $cepsa; #complex dielectric functions
my $cepsb;
my $Nh;

GetOptions("epsa=s" => \$epsa,
	   "epsb=s" => \$epsb,
	   "haydock=s" => \$fhaydock,
	   "od=s" =>  \$od,
	   "Nh=i" => \$Nh,
	  );

die <<"FIN" 
 Use:
    ./fracCont.pl --epsa=dielFunc --epsb=dielFunc --haydock=fileh --od=outputDirectory --Nh=numberOfCoefficients

    Calculate the macroscopic dielectric function for a photonic
    crystal whose geometry is described by the Haydock coefficients
    a=>matrix, b=>inclusion

       --epsa=value/file of eps_a. Values are in format RrealIimag where
                 real and imag are floats. At least one R or I part should 
                 be present
       --epsb=value/file of eps_b (see above)
       --haydock=fileh (file with Haydocks coefficients)
       --Nh=number number of Haydock coefficients
       --od=path     output directory. 
                  Note: The output filenames are built from the input
                  filename by appending the number of desired coefficients 
                  and the extension .dat. 
FIN
  unless defined $epsa and defined $epsb and defined $fhaydock and
  defined $Nh and defined $od;

$cepsa=stringtocomplex($epsa);
$nepsa=defined $cepsa;
my $fepsa=$epsa unless $nepsa;
$cepsb=stringtocomplex($epsb);
$nepsb=defined $cepsb;
my $fepsb=$epsb unless $nepsb;

#read Haydock coefficients and states in one big gulp
printf "\n";
my $ti=time;
my $tf=sprintf "%.2f", ((time-$ti)/60);
printf "\tReading Haydock's coefficients in pld structured format \n";
my $datos=frestore($fhaydock);
#my $datos=$fhaydock->freeze;
printf "\tDone reading in $tf minutes!\n";
printf "\tCalculating the macroscopic eps and other goodies\n";

my ($base, $directorio, $ext)=fileparse($fhaydock, ".pld");

#Get substance names from epsilon file names
my ($elementoa, $elementob);
$elementoa=$1 if !$nepsa and $fepsa=~/^eps_(.*)\.dat$/;
$elementob=$1 if !$nepsb and $fepsb=~/^eps_(.*)\.dat$/;

my $nombre;

# file name if both epsilons are numbers
$nombre= sprintf 
  "${base}_Nh_${Nh}_epsa_%.3f-%.3f_epsb_%.3f-%.3f-dat",
  $cepsa->re, $cepsa->im, $cepsb->re, $cepsb->im 
  if $nepsa and $nepsb;
# $filenames if only epsb number
$nombre= sprintf 
  "${base}_Nh_${Nh}_epsa_%s_epsb_%.3f-%.3f-dat",
  $elementoa, $cepsb->re, $cepsb->im 
  if !$nepsa and $nepsb;
# $filenames if only epsa number
$nombre= sprintf 
  "${base}_Nh_${Nh}_epsa_%.3f-%.3f_epsb_%s-dat",
  $cepsa->re, $cepsa->im, $elementob 
  if $nepsa and !$nepsb;
# $filenames if neither number
$nombre= sprintf 
  "${base}_Nh_${Nh}_epsa_%s_epsb_%s-dat",
  $elementoa, $elementob
  if !$nepsa and !$nepsb;
my $output="${od}eps-${nombre}";
die "Can't open $output" unless open(OUTPUT, "> $output");
#my $outi="ves.dat";
#die "Can't open $outi" unless open(OUTI, "> $outi");
# eps(ij)(ri)=macroscopic eps for (ij)-direction in original axis with (ri)-real or imaginary
# epsnd(ri)=non-diagonal part of macroscopic eps with (ri)-real or imaginary
# pv(12)(ri)=principal value macroscopic eps in principal-(rotated)-axis-(12) with (ri)-real or imaginary
# v(12)(xy)(ri)=principal vectors-(12) along-(xy) with (ri)-real or imaginary
# a(a,b)(12)=angles of (a,b)-ellipse-axis (w.r.t crystal axis) for pv (1,2)
# aa(1,2) perpendicular to ab(1,2)
# nir(12)=Normal Incidence Reflectance for pv (12)  
print OUTPUT "w epsxxr epsxxi epsyyr epsyyi epsxyr epsxyi epsndr epsndi pv1r"
  . " pv1i pv2r pv2i v1xr v1xi v1yr v1yi v2xr v2xi v2yr v2yi aa1 ab1"
  . " aa2 ab2 nir1 nir2 epsar epsai epsbr epsbi a1 b1 a2 b2 ht1 ht2\n";

unless($nepsa){
  open(EPSA, "<", $fepsa) or die "Couldn't open $fepsa";
}
unless($nepsb){
  open(EPSB, "<", $fepsb) or die "Couldn't open $fepsb";
}

my ($freca, $rea, $ima); # frequency, real and im part from files fepsa
my ($frecb, $reb, $imb); # and fepsb 

#iterate over epsilon file rows
while(1){
  unless($nepsa){
    last unless defined ($_=<EPSA>);
    chomp;
    ($freca, $rea, $ima) = split;
    $cepsa = $rea+$ima * i;
  }
  unless($nepsb){
    last unless defined ($_=<EPSB>);
    chomp;
    ($frecb, $reb, $imb) = split;
    $cepsb = $reb+$imb * i;
  }
  $freca=$frecb=1 if $nepsa and $nepsb;
  $freca=$frecb if $nepsa;
  $frecb=$freca if $nepsb;
  die "Frequencies in files $epsa and $epsb differ at line $."
    unless $freca==$frecb;
  my $frec=$freca;
  my $u=1/(1-$cepsb/$cepsa);
  my %dirs=%{$datos->{dirs}};
  my %eps;
  foreach my $dir (sort {$a cmp $b} keys %dirs){
    my @bN2=@{$datos->{bN2}{$dir}};
    my @aN=@{$datos->{aN}{$dir}};
    my $n=0;
    my $M=[[$u-$aN[$n++],1],[1,0]];
    while($n<@aN){
      my $A=[[$u-$aN[$n],1],[-$bN2[$n],0]];
      $M=mult($M,$A);
      $n++;
    }
    my $epsM=$cepsa*$M->[0][0]/$M->[1][0]/$u;
    $eps{$dir}=$epsM;
  }
# Diagonalization for PV eps and PV axis
  my $ebar=($eps{xx}+$eps{yy})/2;
  $eps{nd}=$eps{xy}-$ebar; #non diag part of matrix
  my $det=$eps{xx}*$eps{yy}-$eps{nd}**2; #get principal values
  my $sq=sqrt($ebar**2-$det);
  $sq=0+0*i unless abs($sq) > SMALL;
  my $lam1=$ebar+$sq; #
  my $lam2=$ebar-$sq;
  # eigenvectors
  my $nv1=1/sqrt((abs($eps{nd}))**2+(abs($lam1-$eps{xx}))**2);
  my $v1=$nv1*(pdl($eps{nd},($lam1-$eps{xx})))->cplx; #re-complexize vector
  my $nv2=1/sqrt((abs($eps{nd}))**2+(abs($lam2-$eps{xx}))**2);
  my $v2=$nv2*pdl($eps{nd},($lam2-$eps{xx}))->cplx;
  # extract components
  # v(1,2)(x,y)(p,pp) with (1,2)->eigenvalue, (x,y)->Cartesian directions
  # (p,pp)->(real,imaginary)
  #
  # v1
  #
  my $v1xp=$v1(:,(0))->re;
  my $v1xpp=$v1(:,(0))->im;
  my $v1yp=$v1(:,(1))->re;
  my $v1ypp=$v1(:,(1))->im;
  # helicity
  my $he1=$v1xp*$v1ypp-$v1xpp*$v1yp;
  # helicity-tag
  my $ht1=0;
  if ( $he1 > 0 ){$ht1=1};# Right-handed
  if ( $he1 < 0 ){$ht1=2};# Left-handed
  #
  # v2
  #
  my $v2xp=$v2(:,(0))->re;
  my $v2xpp=$v2(:,(0))->im;
  my $v2yp=$v2(:,(1))->re;
  my $v2ypp=$v2(:,(1))->im;
  # helicity
  my $he2=$v2xp*$v2ypp-$v2xpp*$v2yp;
  # helicity-tag
  my $ht2=0;
  if ( $he2 > 0 ){$ht2=1};# Right-handed
  if ( $he2 < 0 ){$ht2=2};# Left-handed
  #
  # building the eigenvalues of M
  # M1
  my $D1=($v1yp*$v1xpp-$v1xp*$v1ypp)**2;
  my $M1xx=($v1yp**2+$v1ypp**2)/$D1;
  my $M1yy=($v1xp**2+$v1xpp**2)/$D1;
  my $M1xy=-($v1xp*$v1yp+$v1xpp*$v1ypp)/$D1;
  my $tr1=$M1xx+$M1yy;
  my $det1=$M1xx*$M1yy-$M1xy**2;
  my $L1p=($tr1+sqrt($tr1**2-4*$det1))/2;
  my $L1m=($tr1-sqrt($tr1**2-4*$det1))/2;
  my $a1=1/sqrt($L1m);
  my $b1=1/sqrt($L1p);
  # directions of the semiaxis a1,b1
  # tangent a1
  my $ta1=($L1m-$M1xx)/$M1xy;
  # through arcsin
  my $aa1=asin($ta1/sqrt(1.+$ta1**2))*180/PI;
  # tangent b1
  my $tb1=($L1p-$M1xx)/$M1xy;
  # through arcsin
  my $ab1=asin($tb1/sqrt(1.+$tb1**2))*180/PI;
  # through arctan
  #  my $aa1=atan2(($L1m-$M1xx),$M1xy)*180/PI;
  #  my $ab1=atan2(($L1p-$M1xx),$M1xy)*180/PI;
  # M2
  my $D2=($v2yp*$v2xpp-$v2xp*$v2ypp)**2;
  my $M2xx=($v2yp**2+$v2ypp**2)/$D2;
  my $M2yy=($v2xp**2+$v2xpp**2)/$D2;
  my $M2xy=-($v2xp*$v2yp+$v2xpp*$v2ypp)/$D2;
  my $tr2=$M2xx+$M2yy;
  my $det2=$M2xx*$M2yy-$M2xy**2;
  my $L2p=($tr2+sqrt($tr2**2-4*$det2))/2;
  my $L2m=($tr2-sqrt($tr2**2-4*$det2))/2;
  my $a2=1/sqrt($L2m);
  my $b2=1/sqrt($L2p);
  # directions of the semiaxis a2,b2
  # tangent a2
  my $ta2=($L2m-$M2xx)/$M2xy;
  # through arcsin
  my $aa2=asin($ta2/sqrt(1.+$ta2**2))*180/PI;
  # tangent b1
  my $tb2=($L2p-$M2xx)/$M2xy;
  # through arcsin
  my $ab2=asin($tb2/sqrt(1.+$tb2**2))*180/PI;
  # through arctan
  #  my $aa1=atan2(($L1m-$M1xx),$M1xy)*180/PI;
  #  my $ab1=atan2(($L1p-$M1xx),$M1xy)*180/PI;
  # Normal Incidence Reflectance for Principal Axis lam(12)
  my $aux=abs((sqrt($lam1)-1)/(sqrt($lam1)+1));
  my $nir1=$aux*$aux;
  $aux=abs((sqrt($lam2)-1)/(sqrt($lam2)+1));
  my $nir2=$aux*$aux;
  #print everything
#  print OUTI join " ",$frec, (map {$_->list} ($v1,$v2)),"\n";
  printf OUTPUT join " ", $frec, 
    (map {$_->list} ($eps{xx}, $eps{yy}, $eps{xy},
		     $eps{nd}, $lam1, $lam2, $v1, $v2)),$aa1,$ab1,$aa2,$ab2,$nir1,$nir2,$cepsa->re,$cepsa->im,$cepsb->re,$cepsb->im,$a1,$b1,$a2,$b2,$ht1,$ht2, "\n";
  last if $nepsa and $nepsb;
}
printf "\toutput:$output\n\n";

sub mult {
  my ($a, $b)=@_;
  my $c;
  foreach my $i (0,1){
    foreach my $j (0,1) {
      $c->[$i][$j]=$a->[$i][0]*$b->[0][$j]+$a->[$i][1]*$b->[1][$j];
    }
  }
  return $c;
}

sub stringtocomplex {
  my $str=shift @_;
  my($re, $im, $si)=(undef,undef,'+');
  ($re,$im, $si)=($str,0, '+') if looks_like_number($str);
  ($re, $im, $si)=($1,$3, $2) if $str=~/(.*)([+-])i\*(.*)/ &&
    looks_like_number($1) && looks_like_number($3);   
  $im=-$im if $si eq '-';
  return my $cmplx=$re+i*$im if defined $re and defined $im;
  return undef;
}

__END__
