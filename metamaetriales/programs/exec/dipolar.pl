#!/usr/bin/env perl

use strict;
use warnings;
use PDL;
use PDL::Graphics::Gnuplot;
use PDL::NiceSlice;
use PDL::Complex;
use feature qw(say);
$PDL::BIGPDL=1;
use Pod::Usage;
use Getopt::Long;


use constant PI=>4*atan2(1,1);
# defines the variables
#
my ($Nelem,$NR,$f);#(pixels,Max index of interacting lattice vectors,filling fraction)
my ($epsa,$epsb);#dielectric function(host,inculsion)
my ($Zmax,$Zmin);#(Max,Min) values for the image scale
#
# gets the options from the command line
#
GetOptions(
    "Nelem=i" => \$Nelem,
    "NR=i" => \$NR,
    "f=f" => \$f,
    "epsa=s" => \$epsa,
    "epsb=s" => \$epsb,
    "Zmax=f" => \$Zmax,
    "Zmin=f" => \$Zmin,
    );
#
# screen instructions
#
die <<"FIN"

dipolar.pl --Nelem=i --NR=i --f=f --epsa=s --epsb=s --Zmax=f --Zmin=f

                  i=>integer f=>floating point s=>R,I, R&I=>f

    Generate PV angle plots with the corresponding unit cell

    --Nelem=i     Number of pixels
    --NR   =i     Max index of interacting lattice vectors
    --f    =f     Filling Fraction
    --eps[a,b]=c  dielectric function a=host, b=inclusion  
    --Z[max,min]  Max and Min values for the image scale
                  Obtained from the-whole-enchilada.pl

FIN
unless defined $Nelem and defined $NR and defined $f and defined $epsa and defined $epsb
and defined $Zmax and defined $Zmin;
;
#
# the programs begins here
#

my ($re,$im)=split(',',$epsa,2);
$epsa=$re+$im*i;
($re,$im)=split(',',$epsb,2);
$epsb=$re+$im*i;

my $N=($Nelem-1)/2; #max index of unit cell pixels
my $NelemR=2*$NR+1; #number of lattice vectors per side
#my $f=PI*$rDisco**2/$Nelem**2;
my $rDisco=sqrt($f*$Nelem**2/PI); #radio del cilindro
my $alpha=($epsb-$epsa)/($epsb+$epsa)*$rDisco**2/2;
#$alpha=$rDisco**2/(2+0*i);conductor perfecto en vacío
my $EM=pdl(0,1); #macroscopic field
my $p=$alpha/(1-2*$f*$alpha/$rDisco**2)*($EM->r2C);
#my $p=pdl(0,1); #a dipole
my $PD=$p/(PI*$rDisco**2); #polarization within disk.
my $Edep=-2*PI*$PD; #depolarization field within disk

my $r=ndcoords(zeroes($Nelem,$Nelem))-pdl($N,$N); # array of positions
my $R=(ndcoords(zeroes($NelemR,$NelemR))-pdl($NR,$NR))*$Nelem; #lattice vectors

#calculate relative distances;

my $rmR=$r->(,,,*1,*1)-$R->(,*1,*1,,);# xoy, xy indices of r, xy indices of R

my $I=zeroes(2,2); $I->diagonal(0,1).=1; #2x2 unit matrix

# dipole-dipole tensor for each point.
my $T=2*(2*outer($rmR,$rmR)-inner($rmR,$rmR)->(*1,*1)*$I)
    /(inner($rmR,$rmR)->(*1,*1)**2); #xoy,xoy, nx, ny, Nx, Ny
my $Tp=CRinner($p,$T); #dipolar field  #RoI xoy nx, ny, Nx, Ny
$Tp(:,:,0,0,0,0).=0; # remove singularity at origin.
$Tp = $Tp->mv(5,0)->sumover->mv(4,0)->sumover; #sum over lattice vectors.
                                        #RoI xoy nx ny
$Tp->mv(0,3)->mv(0,3)->whereND(inner($r,$r) <= $rDisco**2) .= real($Edep->(*1));

my $E=$Tp->complex+($EM->r2C)+2*PI*$p/$Nelem**2; #RoI XoY nx ny
my $checkE=$E->real->mv(0,3)->mv(0,3)->sumover->sumover/$Nelem**2;
say "EM = $checkE ?";

my $E2=sqrt(Cabs2($E)->sumover);
my $E4=append($E2, $E2);
my $E8=$E4->glue(1, $E4);

my $EN=$E->re; #real part
$EN=$EN/sqrt(inner($EN, $EN)->(*1)); #normalized field
my $rplot=$r(:, 0:-1:20,0:-1:20);
my $ENplot=10*$EN(:, 0:-1:20,0:-1:20);


my $w=gpwin('wxt', size=>[8,6]); #graphics window to visualize
#$w->plot(with=>'image', (Cabs2($E)->sumover), {log=>'cb',cbrange=>[0.65,1.15]});
#$Zmax=$Zmax/150; 
#$Zmin=$Zmin*150;
$w->plot({extracmds=> "set log cb; set cbrange [$Zmax:$Zmin]"},
	 with=>'image', xrange=>[0,2*$Nelem-1], yrange=>[0,2*$Nelem-1], $E8,  
	 with=>'vectors', 
	 lt=>1,
	 $rplot((0))->flat-0.5*$ENplot((0))->flat+$N, 
	 $rplot((1))->flat-0.5*$ENplot((1))->flat+$N, 
	 $ENplot((0))->flat, $ENplot((1))->flat,
	 with=>'vectors', lt=>1,
	 $rplot((0))->flat-0.5*$ENplot((0))->flat+$N+$Nelem-1, 
	 $rplot((1))->flat-0.5*$ENplot((1))->flat+$N, 
	 $ENplot((0))->flat, $ENplot((1))->flat,
	 with=>'vectors', lt=>1,
	 $rplot((0))->flat-0.5*$ENplot((0))->flat+$N, 
	 $rplot((1))->flat-0.5*$ENplot((1))->flat+$N+$Nelem-1, 
	 $ENplot((0))->flat, $ENplot((1))->flat,
	 with=>'vectors', lt=>1,
	 $rplot((0))->flat-0.5*$ENplot((0))->flat+$N+$Nelem-1, 
	 $rplot((1))->flat-0.5*$ENplot((1))->flat+$N+$Nelem-1, 
	 $ENplot((0))->flat, $ENplot((1))->flat,
);
say "Listo? "; <>;
$w->output('png', output=>"rem.png");
$w->replot;

sub CRinner {
    my $c=shift;
    my $r=shift;
    my $tr=inner($c->((0)), $r);
    my $ti=inner($c->((1)), $r);
    return pdl($tr,$ti)->mv(-1,0);
}
__END__
