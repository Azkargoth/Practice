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
use constant c=>'196.6';# in eV*nm
use Inline qw(Pdlpp);

my $ifile;       #input filename
my $ofile;       #output filename
my $na;   #index of refraction of first medium
my $nc;   #index of refraction of last medium
my $df;          #width of film
my $help;        #need help

GetOptions(
    "if=s" => \$ifile,
    "of=s" => \$ofile,
    "na=f"     => \$na,
    "nc=f"     => \$nc,
    "df=f"      => \$df,
    "help|h|?" => \$help,
    );

die <<"FIN"
\n\t calculates the transmission into medium 'c' and reflection to medium 'a' 
\n\t of normal incident light on a medium 'b' characterized by a given index of refraction
\n\t read from an input file 

  \n./tLayer.pl --if=inputFilename --of=outputFile --na=a-index --nc=c-index --df=thicknes

FIN

  unless defined $ifile and defined $ofile and defined $na and defined $nc and defined $df;
  
# input file header
# w epsr epsi

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
my $epsb=$d{epsr}+i*$d{epsi}; #dielectric tensor
#indices of refraction
my $nb=mysqrt($epsb);
# reflection and transmission from a semi-infinite system 
my ($rab, $tab)=getrt($na, $nb);
my $Rab=$rab->Cabs2;
my $Tab=$tab->Cabs2;
#reflection and transmition amplitudes between media a and b and
#between b and c, respectively
my ($r, $t)=getrtabc($w, $na, $nb, $nc);
my $R=$r->Cabs2;
my $T=$nc*($t->Cabs2)/$na;
$ofile="$ofile";
wcols $w, $R, $T,$Rab,$Tab, $ofile,
    {HEADER=>"w R T"}
    || die "Couldn't write $ofile";

# subroutines

# reflection (r) and transmission (t) amplitudes of a film 
sub getrtabc { 
    my ($w, $na, $nb, $nc)=@_;
    my ($rab, $tab)=getrt($na, $nb);
    my ($rbc, $tbc)=getrt($nb, $nc);
    my $k=$nb*$w/c; #wavevector in nm^-1, assuming $w in eV
    my $phi=exp(i*2.0*$k*$df);
    my $r= ($rab+$rbc*$phi)/(1+$rab*$rbc*$phi);
    my $t= $tab*$tbc*$phi/(1.0+$rab*$rbc*$phi);
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
