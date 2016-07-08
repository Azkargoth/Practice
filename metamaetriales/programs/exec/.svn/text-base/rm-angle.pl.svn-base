#!/usr/bin/env perl
use strict;
use warnings;
use PDL;
use PDL::Complex;
use Getopt::Long;
use PDL::IO::Dumper;
use PDL::NiceSlice;
use Scalar::Util qw(looks_like_number);
use File::Basename;
#constants
use constant SMALL=>1e-7;
use constant PI=>4*atan2(1,1);
##
# variables
my ($epsxx,$epsyy,$epsxy);#values of eps-macroscopic
###
GetOptions("epsxx=s" => \$epsxx,
	   "epsyy=s" => \$epsyy,
	   "epsxy=s" => \$epsxy,
	  );

die <<"FIN" 
 Use:
    ./angle.pl --epsxx=f,f  --epsyy=f,f  --epsxy=f,f 

                  f=real 
 
    Calculate the PV angles and vectors

       --eps[ij]  real,imaginary [ij]=xx,yy,xy

FIN
  unless defined $epsxx and defined $epsyy and defined $epsxy;
## calculation begins
# converting to complex values
my ($r,$i)=split(',',$epsxx,2);
$epsxx=$r+$i * i;
($r,$i)=split(',',$epsyy,2);
$epsyy=$r+$i * i;
($r,$i)=split(',',$epsxy,2);
$epsxy=$r+$i * i;
#
#die "Can't open $output" unless open(OUTPUT, "> $output");
#print OUTPUT "w epsxxr epsxxi epsyyr epsyyi epsxyr epsxyi epsndr epsndi pv1r"
#  . " pv1i pv2r pv2i v1xr v1xi v1yr v1yi v2xr v2xi v2yr v2yi tet1r tet1i"
#  . " tet2r tet2i nir1 nir2 epsar epsai epsbr epsbi a1 b1 a2 b2\n";
# Diagonalization for PV eps and PV axis
my $ebar=($epsxx+$epsyy)/2;
my $epsnd=$epsxy-$ebar; #non diag part of matrix
my $det=$epsxx*$epsyy-$epsnd**2; #get principal values
my $sq=sqrt($ebar**2-$det);
$sq=0+0*i unless abs($sq) > SMALL;
my $lam1=$ebar+$sq; #
my $lam2=$ebar-$sq;
# principal directions
my $v1=pdl($epsnd,$lam1-$epsxx)->cplx; #re-complexize vector
my $v2=pdl($epsnd,$lam2-$epsxx)->cplx;
# a1,b1 for elipses
my $e1r=sqrt(($v1(:,(0))->re)**2+($v1(:,(1))->re)**2);
my $e1i=sqrt(($v1(:,(0))->im)**2+($v1(:,(1))->im)**2);
my $e1=sqrt($e1r**2+$e1i**2);
my $a1=$e1r/$e1;
my $b1=$e1i/$e1;
# a2,b2 for elipses
my $e2r=sqrt(($v2(:,(0))->re)**2+($v2(:,(1))->re)**2);
my $e2i=sqrt(($v2(:,(0))->im)**2+($v2(:,(1))->im)**2);
my $e2=sqrt($e2r**2+$e2i**2);
my $a2=$e2r/$e2;
my $b2=$e2i/$e2;
# principal (complex) directions
my $t1=atan2($v1(:,(1)),$v1(:,(0)))*180/PI;
my $t2=atan2($v2(:,(1)),$v2(:,(0)))*180/PI;
# Normal Incidence Reflectance for Principal Axis lam(12)
my $aux=abs((sqrt($lam1)-1)/(sqrt($lam1)+1));
my $nir1=$aux*$aux;
$aux=abs((sqrt($lam2)-1)/(sqrt($lam2)+1));
my $nir2=$aux*$aux;
my $v1xr=$v1(:,(0))->re;
my $v1xi=$v1(:,(0))->im;
my $v1yr=$v1(:,(1))->re;
my $v1yi=$v1(:,(1))->im;
my $v2xr=$v2(:,(0))->re;
my $v2xi=$v2(:,(0))->im;
my $v2yr=$v2(:,(1))->re;
my $v2yi=$v2(:,(1))->im;
print "\tpv1=$lam1 pv2=$lam2\n";
print "\tv1xr=$v1xr v1xi=$v1xi v1yr=$v1yr v1yi=$v1yi\n";
print "\tv2xr=$v2xr v2xi=$v2xi v2yr=$v2yr v2yi=$v2yi\n";
print "\t$t1 $t2\n";
print "\t$e2r $e2i $a2 $b2\n";
#print everything
#  print OUTPUT join " ", $frec, 
#    (map {$_->list} ($eps{xx}, $eps{yy}, $eps{xy},
#		     $eps{nd}, $lam1, $lam2, $v1, $v2, $t1, $t2)),$nir1,$nir2,$cepsa->re,$cepsa->im,$cepsb->re,$cepsb->im,$a1,$b1,$a2,$b2, "\n";
#  last if $nepsa and $nepsb;
__END__
