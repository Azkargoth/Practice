#!/usr/bin/env perl
############################################################################

use strict;
use warnings;
use feature qw(say);
use Getopt::Long;
use PDL;
use PDL::NiceSlice;
#use File::Basename;
use PDL::Complex;
use constant pi=>4*atan2(1,1);
use constant c=>'197.3';# in eV*nm
use Inline qw(Pdlpp);

my $ifile;          #input filename
my $ofile;          #output filename
my $od;             #output directory
my $theta;         #direction of polarization wr x
my $na;     #index of refraction of first medium
my $nc;     #index of refraction of last medium
my $df;            #width of film
my  $help;         #need help

GetOptions(
    "if=s" => \$ifile,
    "of=s" => \$ofile,
    "od=s" => \$od,
    "theta=f"  => \$theta,
    "na=f"     => \$na,
    "nc=f"     => \$nc,
    "df=f"      => \$df,
    "help|h|?" => \$help,
    );

die <<"FIN"
\n\t calculates the transmission into medium 'c' and reflection to medium 'a' 
\n\t of normal incident light on a film characterized by a given index of refraction
\n\t read from an input file 

  \n./tSlab.pl --if=inputFilename --of=outputFile --od=outputDirectory --theta=angle --na=a-index --nc=c-index --df=thicknes

FIN

  unless defined $theta;
  
#w epsxxr epsxxi epsyyr epsyyi epsxyr epsxyi epsndr epsndi pv1r pv1i pv2r pv2i v1xr v1xi v1yr v1yi v2xr v2xi v2yr v2yi aa1 ab1 aa2 ab2 nir1 nir2 epsar epsai epsbr epsbi a1 b1 a2 b2 ht1 ht2
$theta*=pi/180;
my $Ei=pdl(cos($theta), sin($theta)); # incoming field;

my @colids;
my $data=rcols $ifile, [], {COLIDS=>\@colids} || 
    die "Couldn't read $ifile";
my $cnt=0;
my %d;

foreach(@colids){
    $d{$_}=$data->(:,($cnt));
    ++$cnt;
}

my $w=$d{w}; #frequency
my $epsbxx=$d{epsxxr}+i*$d{epsxxi}; #dielectric tensor
my $epsbyy=$d{epsyyr}+i*$d{epsyyi};
my $epsbxy=$d{epsndr}+i*$d{epsndi}; #non-diagonal part of dielectric tensor 
my $Tr=$epsbxx+$epsbyy; #trace
my $Det=$epsbxx*$epsbyy-$epsbxy**2; #determinant
#obtain principal values and vectors;
my $epsb1=($Tr+mysqrt($Tr*$Tr-4*$Det))/2;
my $epsb2=($Tr-mysqrt($Tr*$Tr-4*$Det))/2;
my $norm1=mysqrt(abs($epsbxy)**2+abs($epsb1-$epsbxx)**2);
my $norm2=mysqrt(abs($epsbxy)**2+abs($epsb2-$epsbxx)**2);
my $v1=pdl(-$epsbxy/$norm1, ($epsbxx-$epsb1)/$norm1)->mv(2,1)->complex;
my $v2=pdl(-$epsbxy/$norm2, ($epsbxx-$epsb2)/$norm2)->mv(2,1)->complex;
#my $v1=pdl(-$epsbxy, ($epsbxx-$epsb1))->mv(2,1)->complex;
#my $v2=pdl(-$epsbxy, ($epsbxx-$epsb2))->mv(2,1)->complex;
#Mode basis Modes are numbered 1 and 2
# RoI XoY n
#Dual basis
my $v1p=pdl(-$v1->(:,(1),:), $v1->(:,(0),:))->mv(2,1)->complex;
my $v2p=pdl(-$v2->(:,(1),:), $v2->(:,(0),:))->mv(2,1)->complex;
my $v1d=$v2p/(($v1*$v2p)->sumover->(,*1,));
my $v2d=$v1p/(($v2*$v1p)->sumover->(,*1,));
#Decompose input into normal modes
my $e1=($v1d*($Ei->r2C))->sumover;
my $e2=($v2d*($Ei->r2C))->sumover;
#principal values of epsilon
#indices of refraction
my $nb1=mysqrt($epsb1);
my $nb2=mysqrt($epsb2);
#reflection and transmition amplitudes between media a and b and
#between b and c, respectively
my ($r1, $t1)=getrtabc($w, $na, $nb1, $nc);
my ($r2, $t2)=getrtabc($w, $na, $nb2, $nc);
my $Er=(($e1*$r1)->(,*1))*$v1+(($e2*$r2)->(,*1))*$v2;
my $Et=(($e1*$t1)->(,*1))*$v1+(($e2*$t2)->(,*1))*$v2;
my $R=$Er->Cabs2->sumover;
my $T=$nc*($Et->Cabs2->sumover)/$na;
my $dofile="$od/$ofile"; 
my ($ar, $br, $angler, $helicityr, $flatteningr)=polarization($Er);
my ($at, $bt, $anglet, $helicityt, $flatteningt)=polarization($Et);
wcols $w, $R, $ar, $br, $angler, $flatteningr, $helicityr, $T, $at,
    $bt, $anglet, $flatteningt, $helicityt, $dofile, 
    {HEADER=>"w R ar br angler flatteningr helicityr T at bt anglet flatteningt helicityt"}
    || die "Couldn't write $dofile";
my $mofile="$od/m-$ofile"; #file for mueller matrix
wcols $w,
    $v1->re->mv(1,0), $v1->im->mv(1,0),
    $v2->re->mv(1,0), $v2->im->mv(1,0),
    $v1d->re->mv(1,0), $v1d->im->mv(1,0),
    $v2d->re->mv(1,0), $v2d->im->mv(1,0),
    $r1->mv(1,0), $r2->mv(1,0), $t1->mv(1,0), $t2->mv(1,0),
    $mofile,
    {HEADER=>"w V1xr V1yr V1xi V1yi V2xr V2yr V2xi V2yi V1dxr V1dyr V1dxi V1dyi V2dxr V2dyr V2dxi V2dyi r1r r1i r2r r2i t1r t1i t2r t2i"}
    || die "Couldn't write $mofile";

# subroutines

# reflection (r) and transmission (t) amplitudes of a film 
sub getrtabc { 
    my ($w, $na, $nb, $nc)=@_;
    my ($rab, $tab)=getrt($na, $nb);
    my ($rbc, $tbc)=getrt($nb, $nc);
    my $k=$nb*$w/c; #wavevector in nm^-1, assuming $w in eV
    my $phi2=exp(i*2.0*$k*$df);
    my $phi=exp(i*$k*$df);
    my $r= ($rab+$rbc*$phi2)/(1.0+$rab*$rbc*$phi2);
    my $t= $tab*$tbc*$phi/(1.0+$rab*$rbc*$phi2);
    return($r, $t);
}

# reflection (r) and transmission (t) amplitudes of a semi-infinite medium
sub getrt {
    my ($ni, $nt)=@_; #incoming and transmitted index of refraction
    die "need an array context" unless wantarray;
    return (($ni-$nt)/($ni+$nt), 2*$ni/($ni+$nt));
}

#sqrt in upper half plane
sub mysqrt { #sqrt in upper half plane
    my $r=sqrt($_[0]);
    return $r unless $r->isa("PDL::Complex");
    $r=$r->chooseupper;
    return $r;
  }

#describe polarization of complex vector
sub polarization { #describe polarization of complex vector
    my $v=shift;
    $v=$v->r2C unless $v->isa('PDL::Complex');
    my $D=($v(,(1))->re*$v(,(0))->im - $v(,(0))->re*$v(,(1))->im)**2;
    my $Mxx=$v->(,(1))->Cabs2/$D;
    my $Myy=$v->(,(0))->Cabs2/$D;
    my $Mxy=-($v(,(0))->re*$v(,(1))->re + $v(,(0))->im*$v(,(1))->im)/$D;
    my $trM=$Mxx+$Myy;
    my $detM=$Mxx*$Myy-$Mxy**2;
    my $La=($trM-sqrt($trM**2-4*$detM))/2;
    my $Lb=($trM+sqrt($trM**2-4*$detM))/2;
    my $a=$La->ones;
    my $b=sqrt($La)/sqrt($Lb);
    my $alphaa=atan2($La-$Mxx,$Mxy)*180/pi;
    my $alphab=atan2($Lb-$Mxx,$Mxy)*180/pi;
    die "Axes are not orthogonal" unless 
	all(approx(abs($alphaa-$alphab), 90) | approx(abs($alphaa-$alphab), 270));
    my $helicity=$v(,(0))->re*$v(,(1))->im - $v(,(0))->im*$v(,(1))->re
	<=> 0; #meaning of sign??
    my $flattening=($a-$b)/($a+$b);
    die "Expected list context" unless wantarray;
    return ($a, $b, $alphaa, $helicity, $flattening);
}
    
__DATA__

__Pdlpp__

pp_def(
    'chooseupper',
    Pars=>'i(n=2); [o]o(n);',
    Code=> q{
       if($i(n=>1)<0){
           $o(n=>0)=-$i(n=>0);
           $o(n=>1)=-$i(n=>1);
        } else {
           $o(n=>0)=$i(n=>0);
           $o(n=>1)=$i(n=>1);
        }
     }
    );
