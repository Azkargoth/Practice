#!/usr/bin/env perl
#!/opt/local/bin/perl -w
#/usr/local/bin/perl 
#
# Obtains the vectors and angles for the ellipticity
# of the electric fields according to
# Section "Elliptical Polarization" of how-to-run.pdf 
#
use strict;
use warnings;
use PDL;
use PDL::NiceSlice;
use PDL::Complex;
use constant PI=>4*atan2(1,1);
use constant SMALL=>1e-7;


while(<>){
    chomp;
    my ($w, $epsRxx, $epsIxx, $epsRyy, $epsIyy, $epsRxy, $epsIxy)=
	map {pdl($_)} split;
    my $epsxx=$epsRxx+$epsIxx*i;
    my $epsyy=$epsRyy+$epsIyy*i;
    my $epsxy=$epsRxy+$epsIxy*i;
    my $ebar=($epsxx+$epsyy)/2;
    my $det=$epsxx*$epsyy-$epsxy*$epsxy;
    my $sq=sqrt($ebar**2-$det);
    $sq=0+0*i unless abs($sq) > SMALL;
    my $lam1=$ebar+$sq;
    my $lam2=$ebar-$sq;
    my $v1=cplx(pdl($epsxy,$lam1-$epsxx)); #re-complexize vector
    my $v2=cplx(pdl($epsxy,$lam2-$epsxx));
    if(abs($sq)==0){ # degenerate case: improbable
				# unless isotropic 
	$v1=cplx(pdl(0+0*i,1+0*i));
	$v2=cplx(pdl(1+0*i,0+0*i));
    }
    my $t1=atan2($v1(:,(1)),$v1(:,(0)))*180/PI;
    my $t2=atan2($v2(:,(1)),$v2(:,(0)))*180/PI;
    print "$w @{[$lam1->list]} @{[$lam2->list]} @{[$t1->list]} "
	. "@{[$t2->list]} @{[$v1->list]} @{[$v2->list]} \n";  
}
