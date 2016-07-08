#!/usr/bin/env perl

# calculates the electric field using Haydock's method for a 2D superlatice
# in the long wavelength approximation
# using a file with states and haydock coefficients in the format .pld 
# (PDL::IO::Dumper)

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
# as of jul-22-2013 doesn't work on OS 10.7.5 
#use PDL::Graphics::TriD;
#use PDL::Graphics::Simple;
#use PDL::Graphics::Gnuplot;
use File::Basename;
use PDL::Complex;
use PDL::IO::Misc;
use PDL::IO::Dumper;#frestore
#use Storable;#store
#use PDL::IO::Storable;#freeze
use Scalar::Util qw(looks_like_number);

use constant PI=>4*atan2(1,1);

my ($Nx, $Ny); #max indices for wavevectors
my $Nh; #Max. number of Haydocks coefficients
my ($dx, $dy); #period of structure
my $ifn; #file name 
my $od; #output directory
# eps[a/b]   a=>matrix, b=>inclusion
my $epsa; # filenames or values for eps a, eps b and haydock's coeff.
my $epsb;
my ($nepsa, $nepsb); # flag numeric (vs file) epsilons
my $cepsa; #complex dielectric functions
my $cepsb;
my $angs; # ave=>using average or all=>all the angles
GetOptions(
	   "Nh=i" => \$Nh, 
	   "if=s" => \$ifn,
	   "od=s" => \$od,
	   "epsa=s" => \$epsa,
	   "epsb=s" => \$epsb,
	   "angs=s" => \$angs,
	  );

die <<"FIN"
  \n./caso2DHaydockFields.pl --Nh=i --if=inputFilename --od=outputDirectory
             --epsa= dielectricFunctionA --epsb= dielectricFunctionB 

    Calculates Fields using Haydock coefficients and basis
    for a 2D rectangular lattice
    of inclusions 

    --Nh=i        maximum number of Haydock coefficients
    --if=filename input file (default pld extension) with Haydock coeffs.
                  and basis
    --od=path     output directory. 
                  Note: The output filenames are built from the input
                  filename by appending the number of desired coefficients 
                  and the extension .dat. 
     --eps[a/b]   a=>matrix, b=>inclusion
                  dielectric function value (R+i*I) or file 
                  (R,I) real values; scientific notation accepted 
                  Warning: [+/-]i* must not be separated
     --angs=s     ave=>using average or all=>all the angles

FIN
  unless defined $Nh and defined $ifn and defined $od 
  and defined $epsa and defined $epsb and defined $angs;

# gets the name
my $a1;
my $ejes;
my $figura;
my ($base, $directorio, $ext)=fileparse($ifn, ".pld");
($a1,$a1,$a1,$a1,$ejes)=split('_',$base,6);
my $part="_$ejes";
($figura,$a1)=split($part,$base,6);
$figura="cases/$figura.png";
#printf "\n\n\tontoy:$figura\n\n";
# Lee geometría de la figura.
my ($basef, $dirf, $extf)=fileparse($figura, ".png");
$extf=".png" unless defined $extf;
my $inputf="$dirf$basef$extf";
die "File not readable: $inputf" unless -r $inputf;
# changes the figure to B&W
system "convert $inputf -monochrome $dirf${basef}BW$extf";
$inputf="$dirf${basef}BW$extf";
my $B=rpic $inputf; # changes png file into 0's and 1's
$B = $B==0; #white is matrix and black is inclusion.
unlink $inputf || die "Couldn't remove $inputf: $!";
#die;
#read Haydock coefficients and states in one big gulp
my $datos;
if ("$ejes"eq"crystal"){
  printf "\n\tReading Haydock's coefficients only once (crystal axes) in pld structured format\n";
  my $ti=time;
  $datos=frestore($ifn);
#  $datos=$ifn->freeze;
  my $tf=sprintf "%.2f", ((time-$ti)/60);
  printf "\tDone in $tf minutes!\n";
}
if ("$angs"eq"ave"){
  printf "\tReading Haydoc's coefficients only once in pld structured format\n";
  my $ti=time;
  $datos=frestore($ifn);
#  $datos=$ifn->freeze;
  my $tf=sprintf "%.2f", ((time-$ti)/60);
  printf "\tDone in $tf minutes!\n";
}
if ("$angs"eq"all"){
  printf "\tReading each HC in pld structured format\n";
  # extracting the energy, epsa and epsb from the file name
  my ($eV,$ea,$eb,$pa,$du);
  ($du,$pa,$du,$du)=split('vsw_',$base,4);
  ($pa,$du,$du,$du)=split('_',$pa,4);
  ($du,$eV)=split('W',$pa,2);
  # extracting epsa from the file name
  ($du,$pa,$du,$du)=split('epsa_',$base,4);
  ($ea,$du,$du,$du)=split('-epsb',$pa,4);
  # extracting epsb from the file name
  ($du,$eb,$du,$du)=split('epsb_',$base,4);
  #assigns the dielectric values 
  $epsa=$ea;
  $epsb=$eb;
  printf "\tFor eV=$eV epsa=$ea epsb=$eb\n";
  my $ti=time;
  $datos=frestore($ifn);
#  $datos=$ifn->freeze;
  my $tf=sprintf "%.2f", ((time-$ti)/60);
  printf "\tDone in $tf minutes!\n";
}
# gets the correct values of epsa and epsb
$cepsa=stringtocomplex($epsa);
$nepsa=defined $cepsa;
my $fepsa=$epsa unless $nepsa;
$cepsb=stringtocomplex($epsb);
$nepsb=defined $cepsb;
my $fepsb=$epsb unless $nepsb;


#Get substance names from epsilon file names
my ($elementoa, $elementob);
$elementoa=$1 if !$nepsa and $fepsa=~/^eps_(.*)\.dat$/;
$elementob=$1 if !$nepsb and $fepsb=~/^eps_(.*)\.dat$/;

unless($nepsa){
  open(EPSA, "<", $fepsa) or die "Couldn't open $fepsa";
}
unless($nepsb){
  open(EPSB, "<", $fepsb) or die "Couldn't open $fepsb";
}

my ($freca, $rea, $ima); # frequency, real and im part from files fepsa
my ($frecb, $reb, $imb); # and fepsb 

my $nombre3;
# file name if both epsilons are numbers
$nombre3= sprintf 
  "${base}_Nh_${Nh}_epsa_%.3f-%.3f_epsb_%.3f-%.3f",
  $cepsa->re, $cepsa->im, $cepsb->re, $cepsb->im 
  if $nepsa and $nepsb;
# $filenames if only epsb number
$nombre3= sprintf 
  "${base}_Nh_${Nh}_epsa_%s_epsb_%.3f-%.3f",
  $elementoa, $cepsb->re, $cepsb->im 
  if !$nepsa and $nepsb;
# $filenames if only epsa number
$nombre3= sprintf 
  "${base}_Nh_${Nh}_epsa_%.3f-%.3f_epsb_%s",
  $cepsa->re, $cepsa->im, $elementob 
  if $nepsa and !$nepsb;
# $filenames if neither number
$nombre3= sprintf 
  "${base}_Nh_${Nh}_epsa_%s_epsb_%s",
  $elementoa, $elementob 
  if !$nepsa and !$nepsb;
my $outPyPEM="${od}p-${nombre3}";
die "Can't open $outPyPEM" unless open(OUTPYPEM, "> $outPyPEM");
print OUTPYPEM "w xpPxrd xpPxid xpPyrd xpPyid xpPxrf xpPxif xpPyrf xpPyif xpPErd xpPEid xpPErf xpPEif ypPxrd ypPxid ypPyrd ypPyid ypPxrf ypPxif ypPyrf ypPyif ypPErd ypPEid ypPErf ypPEif\n";

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
  
  my $u=1/(1-$cepsb/$cepsa); #spectral function u(w)
  # iterate over desired directions
  my %dirs=%{$datos->{dirs}};
  my %polarizaciones;
  foreach my $dir (sort {$a cmp $b} keys %dirs){
    my $states=$datos->{states}{$dir};
    my $bN2=$datos->{bN2}{$dir};
    my $aN=$datos->{aN}{$dir};
    my @EN;
    my $q=$dirs{$dir};
    # output file for fields
    die "\tNh too large. Should be smaller than \@\$aN\n" if $Nh > scalar @$aN;
    my $nombre;
    # file name if both epsilons are numbers
    $nombre= sprintf 
      "${base}_Nh_${Nh}_epsa_%.3f-%.3f_epsb_%.3f-%.3f_dir_${dir}-dat",
	$cepsa->re, $cepsa->im, $cepsb->re, $cepsb->im 
	  if $nepsa and $nepsb;
    # $filenames if only epsb number
    $nombre= sprintf 
      "${base}_Nh_${Nh}_epsa_%s_W%.3f_epsb_%.3f-%.3f_dir_${dir}-dat",
	$elementoa, $frec, $cepsb->re, $cepsb->im 
	  if !$nepsa and $nepsb;
    # $filenames if only epsa number
    $nombre= sprintf 
      "${base}_Nh_${Nh}_epsa_%.3f-%.3f_epsb_%s_W%.3f_dir_${dir}-dat",
	$cepsa->re, $cepsa->im, $elementob, $frec 
	  if $nepsa and !$nepsb;
    # $filenames if neither number
    $nombre= sprintf 
      "${base}_Nh_${Nh}_epsa_%s_epsb_%s_W%.3f_dir_${dir}-dat",
	$elementoa, $elementob, $frec 
	  if !$nepsa and !$nepsb;
    my $outE="${od}e-${nombre}";
    die "Can't open $outE" unless open(OUTE, "> $outE");
    my $ww=sprintf "%.2f", $frec;
    if ($nepsa and $nepsb){
      printf "\tRunning for $dir\n";
    }
    else{
      printf "\tRunning for $dir and w=$ww\n";
    }
    #printf STDERR "\tField: $outE\n";
    my $outP="${od}p-${nombre}";
    die "Can't open $outP" unless open(OUTP, "> $outP");
    #printf STDERR "\tPol: $outP\n";
    # output file for vectors
    my $outEV="${od}e-${nombre}-v";
    #printf STDERR "\tE-Vectors: $outEV\n";
    my $outPV="${od}p-${nombre}-v";
    #printf STDERR "\tP-Vectors: $outPV\n";
    #
    my (undef, $Nelx, $Nely)=$states->[0]->dims;
    my $Nel=my $d=pdl($Nelx, $Nely);
    die "\tThe size of the image must be odd\n" unless all $Nel%2==1;
    my $N=($Nel-1)/2;
    ($Nx, $Ny)=$N->list;
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
    $gnorm(,$N(0),$N(1)).=$q->norm ; #establish direction of vec 0
    # First get cartesian index out of the way, then
    # rotate each index and then restore order of indices
    my $gnormrot=$gnorm->mv(0,2)->
      rotate(-$Nx)->transpose->rotate(-$Ny)->transpose->mv(2,0);
    
    # The calculation of the E-fields begins
    my $ENM1=0+i*0;
    my $EN=1+i*0;
    unshift @EN, $EN;
    # obtain field coefficients
    for(my $n=$Nh-1; $n>0;--$n){
      my $bNM1=sqrt($bN2->[$n+1]);
      my $bn=sqrt($bN2->[$n]);
      my $ENm1=(($u-$aN->[$n])*$EN-$bNM1*$ENM1)/$bn;
      unshift @EN, $ENm1;
      $ENM1=$EN;
      $EN=$ENm1;
    }
    my $norm=$EN[0];
    #calculate field in reciprocal space
    my $fieldReciprocal=zeroes(2,2,$Nel->at(0),$Nel->at(1));  
    for(my $n=0; $n< @EN; ++$n){
      $EN[$n]=$EN[$n]/$norm; #normalize to macroscopic field
      #states are RorI, nx, ny. gnormrot is XorY, nx, ny
      # $gvecN is RorI, XorY, nx,ny
      my $gvecN=Cscale($states->[$n],$gnormrot->mv(0,2))->mv(3,1);
      my $Engvec=Cmul($gvecN,$EN[$n]);
      # fieldReciprocal RorI, XorY, nx, ny
      $fieldReciprocal += $Engvec;
    }
    #filter large wavevectors (outside some disk)
    my $filter=zeroes($Nel->at(0), $Nel->at(1))->rvals<=.5*$Nel->at(0);
    $filter=$filter->rotate($Nx)->transpose->rotate($Ny)->transpose;
    $fieldReciprocal *= $filter->(*1,*1,,);
    #take 2D fourier transform over nx, ny
    my $tmp0=ifftw($fieldReciprocal->(,((0)),)); 
    my $tmp1=ifftw($fieldReciprocal->(,((1)),));
    #$tmp0 -= 1 if $dir eq 'x';
    #$tmp1 -= 1 if $dir eq 'y';
    my $fieldRealSpace=cat($tmp0, $tmp1); #RorI, nx, ny, XoY
    #DEBUG Check that field is around 1
    my $checkfield=$fieldRealSpace->mv(0,2)->sumover->sumover/($Nelx*$Nely);
    $checkfield=$checkfield->Cmod2->sumover; 
    #printf STDERR "Macroscopic field $checkfield Is it 1?\n";
    my $Brot=$B->rotate($Nx)->transpose->rotate($Ny)->transpose;
    # Polarización dentro y fuera de la partícula.
    my $norma=($Nelx*$Nely);
    my $polarizacionDentro=
      Cmul(($cepsb-1)/(4*PI*$norma),
	   ($Brot(*1, , ,*1)*
	    ($fieldRealSpace)))->real ; # RorI nx ny XoY 
    my $polarizacionFuera=
      Cmul(($cepsa-1)/(4*PI*$norma),
	   ((1-$Brot(*1, , ,*1))*
	    ($fieldRealSpace)))->real; #  RorI nx ny XoY 
    my $polRealSpace = ($polarizacionDentro+$polarizacionFuera);# RorI nx ny XoY 
    $polarizacionDentro = $polarizacionDentro->mv(0,2)->sumover->sumover;
    $polarizacionFuera = $polarizacionFuera->mv(0,2)->sumover->sumover;
    my $field2= $fieldRealSpace->Cmod2->mv(2,0)->sumover->
      rotate($Nx)->transpose->rotate($Ny)->transpose; #nx,ny
    die "\t$field2 negative\n" if any($field2<0);
    my $fieldabs=$field2->sqrt;
    my $pol2= $polRealSpace->Cmod2->mv(2,0)->sumover->
      rotate($Nx)->transpose->rotate($Ny)->transpose; #nx,ny
    die "\t$field2 negative\n" if any($field2<0);
    my $polabs=$pol2->sqrt;
#    printf "$polabs\n";
    #    my $field2= $fieldRealSpace->Cmod2->mv(2,0)->sumover; #nx,ny
    # Escalamiento para visualizar campos dipolares
    #    my $field1=.1*$fieldRealSpace->((0))
    #	->rotate($Nx)->mv(0,1)->rotate($Ny)->mv(1,0)->mv(2,0)
    #	*$field2->rvals->(*1)**2;
    #my $field1=$fieldRealSpace->((0))
    #    ->rotate($Nx)->mv(0,1)->rotate($Ny)->mv(1,0)->mv(2,0)/$fieldabs->(*1);
    my $field1=$fieldRealSpace->((0))
      ->rotate($Nx)->mv(0,1)->rotate($Ny)->mv(1,0)->mv(2,0);
    my $pol1=$polRealSpace->((0))
      ->rotate($Nx)->mv(0,1)->rotate($Ny)->mv(1,0)->mv(2,0);
    my $coords=ndcoords($field1((0)));
    my $asepx=(($Nelx-1)/10);
    my $asepy=(($Nely-1)/10);
    my $tama=(($Nelx-1)/8);
    $coords=$coords(,0:-1:$asepx,0:-1:$asepy)->clump(1,2);
    #$field1=$tama*$field1(,0:-1:$asepx,0:-1:$asepy)->clump(1,2);
    my $fieldabsmax=$fieldabs->(0:-1:$asepx,0:-1:$asepy)->flat->maximum;
    $field1=$tama*$field1(,0:-1:$asepx,0:-1:$asepy)->clump(1,2)
      /$fieldabsmax;
    my $polabsmax=$polabs->(0:-1:$asepx,0:-1:$asepy)->flat->maximum;
    $pol1=$tama*$pol1(,0:-1:$asepx,0:-1:$asepy)->clump(1,2)
      /$polabsmax;
    # campo macroscopico
    my $campoM=$fieldRealSpace->mv(0,2)->sumover->sumover/$norma; # RoI XoY 
    #print STDERR "Campo M imaginario=", $campoM->((1)), " ¿es 0?\n";
    #print STDERR "Campo M real=", $campoM->((0)), " ¿es 1? \n ";
    $campoM=$campoM->((0));
    $polarizaciones{$dir}{dentro}=$polarizacionDentro;
    $polarizaciones{$dir}{fuera}=$polarizacionFuera;
    $polarizaciones{$dir}{pdentro}=
      inner($campoM, $polarizacionDentro->transpose); #RoI
    $polarizaciones{$dir}{pfuera}=
      inner($campoM, $polarizacionFuera->transpose); #RoI
    ###
    # Output section
    ###
    # for the vector field
    # coord(x), coord(y), field1(x) y field1(y). 
    my $tmp=transpose(append($coords,$field1)); 
    wcols $tmp,  "$outEV";
    $tmp=transpose(append($coords,$pol1)); 
    wcols $tmp,  "$outPV";
    ###
    ###
    # prints the data as x,y,|field(x,y)|
    # within gnuplot we can generate a grid of unit cells
    # with one single unit cell
    ###
    my $inix=0;
    while($inix++<(2*$Nx+1)){
      my $iniy=0;
      while($iniy++<(2*$Ny+1)){
	#
	# prints the data as x,y,log_10(|field(x,y)|)
	#my $chin=$field2->(($inix-1),($iniy-1))->sqrt->log10;      
	# prints the data as x,y,|field(x,y)|
	my $chin=$fieldabs->(($inix-1),($iniy-1));      
	# prints the data as x,y,|field(x,y)|^2
	#	my $chin=$field2->(($inix-1),($iniy-1));      
	print OUTE "$inix $iniy $chin\n";      
      }
      print OUTE "\n";
    }
    
    ###
    # prints the data as x,y,|pol(x,y)|
    # within gnuplot we can generate a grid of unit cells
    # with one single unit cell
    ###
    $inix=0;
    while($inix++<(2*$Nx+1)){
      my $iniy=0;
      while($iniy++<(2*$Ny+1)){
	#
	# prints the data as x,y,log_10(|field(x,y)|)
	#my $chin=$field2->(($inix-1),($iniy-1))->sqrt->log10;      
	# prints the data as x,y,|field(x,y)|
	my $chin=$polabs->(($inix-1),($iniy-1));      
	# prints the data as x,y,|field(x,y)|^2
	#	my $chin=$field2->(($inix-1),($iniy-1));      
#	printf "$inix $iniy $chin\n" if $chin==0;      
	print OUTP "$inix $iniy $chin\n";      
      }
      print OUTP "\n";
    }
    
    ###
    # Self-generated Nice plots
    #
    #    my $w=gpwin('wxt', size=>[8,6]);
    #    my $w=gpwin('png', output=>'rem.png', size=>[8,6], wait=>20);
    # $field2=append($field2,$field2)->mv(0,1);
    # $field2=append($field2,$field2)->mv(1,0);
    # $w->plot({xr=>[0,202], yr=>[0,202]},with=>'image',$field2->sqrt->log10,
    # 	      {lt=>1, lc=>2}, 
    # 	     with=>'vectors',
    # 	     $coords((0))-.5*$field1((0)), 
    # 	     $coords((1))-.5*$field1((1)), 
    # 	     $field1((0)), $field1((1)),
    # 	     with=>'vectors',
    # 	     $coords((0))-.5*$field1((0))+$Nel((0)), 
    # 	     $coords((1))-.5*$field1((1)), 
    # 	     $field1((0)), $field1((1)),
    # 	     with=>'vectors',
    # 	     $coords((0))-.5*$field1((0)), 
    # 	     $coords((1))-.5*$field1((1))+$Nel((1)), 
    # 	     $field1((0)), $field1((1)),
    # 	     with=>'vectors',
    # 	     $coords((0))-.5*$field1((0))+$Nel((0)), 
    # 	     $coords((1))-.5*$field1((1))+$Nel((1)), 
    # 	     $field1((0)), $field1((1)),
    # 	);
    ###
    #    print "Enter to continue";
    #    <>;
    # final line for the screen
    #	print "\n";
  }
  #    printf "\n\tPolarization: $outPyPEM\n";
  print OUTPYPEM "$frec ";
  foreach my $dir (sort {$a cmp $b} keys %polarizaciones){
    #print " $dir ";
    foreach my $lugar (qw(dentro fuera pdentro pfuera)){
      my $pol = $polarizaciones{$dir}{$lugar};
      print OUTPYPEM join " ", $pol->flat->list, " ";
    }
  }
  print OUTPYPEM "\n";
  last if $nepsa and $nepsb;
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


gnuplot: 
   # da nombre a los archivos
   a='archivo1.dat'
   b='archivo2.dat'
   # combina columnas de distintos archivos al graficar archivos 
   splot "<paste ".a." ".b using 1:2:($3-$6)
   splot "<paste archivo1.dat archivo2.dat"...
