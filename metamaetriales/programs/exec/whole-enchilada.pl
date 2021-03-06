#!/usr/bin/env perl
#######################
use strict;
use warnings;
use PDL;
use PDL::Complex;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);
use File::Basename;
use Pod::Usage;
#
# scale factor for color maps
my $sfcm=150;
# reads input
#path where the programs are located in your computer
#read from PWD/.ruta
my $ruta=`awk '{print \$1}' .ruta`;
$ruta=~s/\s+//g;
# programs
my $exe_base="$ruta/haydock2DNRBase.pl"; 
my $exe_fields="$ruta/corre-fields.pl"; 
my $exe_frac="$ruta/fracCont.pl"; 
my $exe_arrows="$ruta/corre-arrows.pl"; 
my $exe_angarr="$ruta/corre-angles.pl"; 
my $exe_plots="$ruta/corre-plots.pl"; 
my $exe_3g="$ruta/corre-3g.pl"; 
my $exe_4g="$ruta/corre-4g.pl"; 
my $exe_principal="$ruta/corre-principal-axes.pl"; 
my $exe_maxmin="$ruta/max-min.pl"; 
my $execawk="$ruta/chose-column.awk";
my $exe_acomoda="$ruta/rcontinuous-eps";
# Options
my $od; #output directory
my $scale; #scale
my $angle; #angle
my $Nh;#Haydock's coefficients
my $epsa;#material or value R-I
my $epsb;#material or value R-I
my $axes;#crystal or principal
my $nem;#ave=>average or vsw=>vs energy
my $fields;#yes or no
my ($nepsa, $nepsb); # flag numeric (vs file) epsilons
my $cepsa;
my $cepsb;
my $cual;# ronly=>only reflection all=>reflection and fields
my $fixedangle; #fixed angle
#
GetOptions(
	   "Nh=i" => \$Nh,
	   "epsa=s" => \$epsa,
	   "epsb=s" => \$epsb,
	   "axes=s" => \$axes,
	   "nem=s" => \$nem,
	   "fields=s" => \$fields,
	   "cual=s" => \$cual,
	   "fixedangle=f" => \$fixedangle,
	  );
#
# screen instructions
#
die <<"FIN"

ls cases/figure*.png | whole-enchilada.pl --Nh=i --epsa=s --epsb=s --axes=s --nem=s --fields=s
                                          --cual=s [--fixedangle=f]

             s=>string f=>real i=integer 

    Generate plots with arrows following the Reflectance spectrum

          --Nh=i      Haydock's coefficients            
        --epsa=s      material or value R-I
        --epsb=s      material or value R-I
        --axes=s      crystal or principal
         --nem=s      ave=>average or vsw=>vs energy
      --fields=s      yes or no
        --cual=s      ronly=>only reflection all=>reflection and fields
  --fixedangle=f      [Optional] Fixed Polarization Angle 

FIN
  unless defined $Nh and defined $epsa and defined $epsb and defined $axes and defined $fields and defined $cual;

if ("$axes"ne"crystal" and "$axes"ne"principal") {
die "\n\t--axes must be crystal or principal\n\n";
}
if ("$axes"eq"principal") {
  die "\n\tprincipal axes: give a value for --nem [ave/vsw]\n\n" unless defined $nem;
}
# gets the names for the files
my ($duu,$mate);
($duu,$mate)=split('eps_',$epsa,2);
($mate,$duu)=split('.dat',$mate,2);
#printf "\t $mate\n";
#die;
# gets the names for the files
my $nombre;
&mynamesub($epsa,$epsb,$nombre);
######&&&& Axes=Crystal &&&&BEGIN######
if ("$axes"eq"crystal") {
  printf "\n\tHold on to what is yours!!\n";
  printf "\tYou have chosen:";
  printf "\n\t--axes=$axes\n";
  printf "\tthen we calculate the HC along the crystal axes\n";
  printf "\tand determine the macroscopic epsilon along principal axes,\n";
  printf "\tfrom where we obtain the variation of theta vs. w\n\n";
  while(<>) {
    chomp(my $caso=$_);
    my ($du,$pa,$angu,$sca);
    my ($base, $dir, $ext)=fileparse($caso, ".png");
    my ($figure,$data)=split('_',$base,2);
    # size of the figure
    # changes the figure to B&W
    system "convert $caso -monochrome $dir${base}BW$ext";
    my $input="$dir${base}BW$ext";
    my $B=rpic $input; # changes png file into 0's and 1's
    $B = $B==0; #white is matrix and black is inclusion.
    my ($Nx,$Ny);
    pdl(($Nx,$Ny)=$B->dims);
    system "rm $input";
    # from $base gets values
    # rotation angle of the inclusion
    ($du,$pa)=split('_A',$base,2);
    ($angu,$du)=split('_',$pa,2);
    # scaling of the inclusion
    ($du,$pa)=split('_S',$base,2);
    ($sca,$du)=split('_',$pa,2);
    my $hc="hc/$base\_$axes.pld";
    if (-e $hc){
      &myline;
      printf "\t$hc exists\n"; 
      printf "\ttherefore there is no need to calculate it again\n"; 
      &myline;
    }
    else{
      #
      # Haydock coefficients along the crystal axes: Must be done
      # regardless of whether principal axes are used or not. 
      printf "\tHaydock coefficients along the crystal axes: A must!\n"; 
      printf "\tRunning for $caso\n"; 
      system "$exe_base --Nh=$Nh --if=$caso --od=hc/ --axes=crystal";
    }
    #
    my $mepsm="meps/eps-$base\_$axes\_$nombre-dat";
    if (-e $mepsm){
      &myline;
      printf "\t$mepsm exists\n"; 
      printf "\ttherefore there is no need to calculate it again\n"; 
      &myline;
    }
    else{
      printf "\n\tPrincipal axis eps and angles with HC from previous run; using crystal axes\n";
      system "$exe_frac --epsa=$epsa --epsb=$epsb --haydock=hc/$base\_crystal.pld --od=meps/ --Nh=$Nh";
#
# New: we make aa(1,2) continuous when they flip from one to the other. 
#      The 180 degree 'discontinuities' are left as they are
#      since we plot the axis direction and its 180 degree replica.
#      The original epsm* is kept as epsm*-original, 
#      so be sure that the algorithm is doing what it is suppose to do!
#
      if (1 eq 1){
	&myline;
	printf "\tFlipping 1 \<-\> 2\n\n";
	system "cp $mepsm $mepsm-original";
	system "cp $mepsm fort.1";
	my $nw=`wc fort.1 | awk '{print \$1}'`;
	$nw=$nw-1;
	system "echo $nw | $exe_acomoda";
	system "mv fort.2 $mepsm";
	system "rm fort.1";
	printf "\n\tDone!\n";
	&myline;
      };
#
    }
    if ("$cual"eq"all") { #by pass for only reflection and goodies
      printf "\tCalculating the pointing arrows vs. w for R\n";
      printf "\tso fast that we do it again, let the electrons suffer!\n";
      system "$exe_arrows --od=arrows/ --idf=$mepsm --tam=0.1";
      # plot theta[1,2] vs w, to decide how is its variation w.r.t w 
      printf "\n\tUse plot-angles.pl to see how is the variation of theta vs w\n";
      printf "\tRun with --axes=principal and:\n"; 
      printf "\tfor small theta.vs.w variation use --nem=small\n";
      printf "\tfor big   theta.vs.w variation use --nem=big\n\n";
      &myline;
      printf "\tCalculating the pointing arrows vs. w for angles\n";
      system "$exe_angarr --od=arrows/ --idf=$mepsm --tam=15";
      &myline;
    }
    # Fields
    if ("$fields"eq"void") {
      #if ("$fields"eq"yes"){
      printf "\n\tFields are calculated for polarization along the crystal axes\n";
      printf "\tfor $hc\n";
      system "ls $hc | $exe_fields --Nh=$Nh --od=res/ --epsa=$epsa --epsb=$epsb";
      printf "\tGenerates the E-field and Polarization maps for incidence along crystal axes\n";
      my $eb;
      ($du,$eb)=split('epsb_',$nombre,2);
      my $efxx="e-$base\_$axes\_$du*epsb\_$eb*xx-dat";
      my $efyy="e-$base\_$axes\_$du*epsb\_$eb*yy-dat";
      system "ls res/$efxx | sort -tW -n -k 2 | $exe_plots -Nx=$Nx -Ny=$Ny --od=plots/ --cell=2";
      system "ls res/$efyy | sort -tW -n -k 2 | $exe_plots -Nx=$Nx -Ny=$Ny --od=plots/ --cell=2";
      printf "\n\tDone for xx and yy!\n";
      #Movies for crystal axes
      &myline;
      printf "\tMovies for Crystal Axes\n";
      printf "\tElectric Field\n";
#      system "$exe_3g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=crystal --ep=e";
      system "$exe_4g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=crystal --ep=e";
      printf "\tPolarization\n";
#      system "$exe_3g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=crystal --ep=p";
      system "$exe_4g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=crystal --ep=p";
    } #void
  } #while
} #crystal
######&&&& AXES=Crystal &&&&END######
######&&&& Axes=Principal &&&&BEGIN######
if ("$axes"eq"principal") {
  printf "\n\tHold on to what is yours!!\n";
  printf "\tYou have chosen:";
  printf "\n\t--axes=$axes with $nem\n";
  printf "\tthen we calculate the HC along the principal axes according to $nem\n";
  printf "\tand determine the fields along principal axes\n";
  while(<>){
    chomp(my $caso=$_);
    # get the name from $caso
    my ($base, $dir, $ext)=fileparse($caso, ".png");
    my ($figure,$data)=split('_',$base,2);
    my ($du,$pa,$angu,$sca);
    # size of the figure
    # changes the figure to B&W
    system "convert $caso -monochrome $dir${base}BW$ext";
    my $input="$dir${base}BW$ext";
    my $B=rpic $input; # changes png file into 0's and 1's
    $B = $B==0; #white is matrix and black is inclusion.
    my ($Nx,$Ny);
    pdl(($Nx,$Ny)=$B->dims);
    system "rm $input";
    # from $base gets values
    # rotation angle of the inclusion
    ($du,$pa)=split('_A',$base,2);
    ($angu,$du)=split('_',$pa,2);
    # scaling of the inclusion
    ($du,$pa)=split('_S',$base,2);
    ($sca,$du)=split('_',$pa,2);
    # always use crystal axes for eps macroscopic since here are the angles
    # for the principal axes
    my $mepsm="meps/eps-$base\_crystal\_$nombre-dat";
#    printf "\tAQUI:$mepsm\n";
    #obtains the angle for the principal axes
    system "awk -f $execawk -v colname=aa1 $mepsm > ang1.rem";
    my $angp=`head -1 ang1.rem`;
    $angp=~s/\s+//g;
    $angp=sprintf "%.2f", $angp;
    ## fixed angle
    if(defined $fixedangle){
      $angp=$fixedangle;
      &myline;
	printf "\tAngulo=$angp\n";
      &myline;
    }
    ##
    # name of HC for principal axes
    my $hc="hc/$base\_$axes\_$angp\_ave.pld";
    if ("$nem"eq"ave"){
      if (-e $hc){
	&myline;
	printf "\n\t$hc exists\n"; 
	printf "\ttherefore there is no need to calculate it again\n"; 
	&myline;
      }
      else{
	printf "\n\tHaydock coefficients along the principal axes for average theta\n" if(!defined $fixedangle); 
	printf "\n\tHaydock coefficients along fixed axes\n" if(defined $fixedangle); 
	printf "\tRunning for $caso\n"; 
	system "$exe_principal --od=hc/ --Nh=$Nh --epsm=$mepsm --tvsw=small" if(!defined $fixedangle);
	system "$exe_principal --od=hc/ --Nh=$Nh --epsm=$mepsm --tvsw=small --fixedangle=$fixedangle" if(defined $fixedangle);
      }
      # Fields
      if ("$fields"eq"yes"){
	my $hc="hc/$base\_$axes*\_ave.pld";
	printf "\n\tFields are calculated for polarization along the principal average axes\n" if(!defined $fixedangle);
	printf "\n\tFields are calculated for polarization along fixed axes\n" if(defined $fixedangle);
	system "ls $hc | $exe_fields --Nh=$Nh --od=res/ --epsa=$epsa --epsb=$epsb";
	printf "\tGenerates the Efield and Polarization plots for incidence along principal average axes\n";
	my $eb;
	($du,$eb)=split('epsb_',$nombre,2);
	printf "\tElectric Fields\n";
	# first obtain the zmax and zmin of both xp and yp
	my $efxy="e-$base\_$axes*ave\_Nh\_$Nh\_epsa_*\_epsb\_$eb*-dat";
	system "ls res/$efxy | sort -tW -n -k 2 | $exe_maxmin -gogo=yes";
	# read Zmax and Zmin of both xp and yp
	my $zmax=`awk '{print \$1}' .maxmin`;
	$zmax=~s/\s+//g;
	my $zmin=`awk '{print \$2}' .maxmin`;
	$zmin=~s/\s+//g;
	$zmax/=$sfcm;
	$zmin*=$sfcm;
	die "Can't open .emaxmin" unless open(OUTPUTa, "> .emaxmin");
	print OUTPUTa "$zmax $zmin";
#	printf "\tZmin=$zmin Zmax=$zmax\n";
	# now, the plots
	my $efxx="e-$base\_$axes*ave\_Nh\_$Nh\_epsa_*\_epsb\_*xp-dat";
	my $efyy="e-$base\_$axes*ave\_Nh\_$Nh\_epsa_*\_epsb\_*yp-dat";
	system "ls res/$efxx | sort -tW -n -k 2 | $exe_plots -Nx=$Nx -Ny=$Ny --od=plots/ --cell=2 --zmax=$zmax --zmin=$zmin";
	system "ls res/$efyy | sort -tW -n -k 2 | $exe_plots -Nx=$Nx -Ny=$Ny --od=plots/ --cell=2 --zmax=$zmax --zmin=$zmin";
	printf "\n\tDone for xp and yp!\n";
	printf "\n\tPolarization\n";
	# first obtain the zmax and zmin of both xp and yp
	$efxy="p-$base\_$axes*ave\_Nh\_$Nh\_epsa_*\_epsb\_$eb*-dat";
	system "ls res/$efxy | sort -tW -n -k 2 | $exe_maxmin -gogo=yes";
	# read Zmax and Zmin of both xp and yp
	$zmax=`awk '{print \$1}' .maxmin`;
	$zmax=~s/\s+//g;
	$zmin=`awk '{print \$2}' .maxmin`;
	$zmin=~s/\s+//g;
	$zmax/=$sfcm;
	$zmin*=$sfcm;
	die "Can't open .pmaxmin" unless open(OUTPUTb, "> .pmaxmin");
	print OUTPUTb "$zmax $zmin";
#	printf "\tZmin=$zmin Zmax=$zmax\n";
	# now, the plots
	my $pfxx="p-$base\_$axes*ave\_Nh\_$Nh\_epsa_*\_epsb\_$eb*xp-dat";
	my $pfyy="p-$base\_$axes*ave\_Nh\_$Nh\_epsa_*\_epsb\_$eb*yp-dat";
	system "ls res/$pfxx | sort -tW -n -k 2 | $exe_plots -Nx=$Nx -Ny=$Ny --od=plots/ --cell=2 --zmax=$zmax --zmin=$zmin";
	system "ls res/$pfyy | sort -tW -n -k 2 | $exe_plots -Nx=$Nx -Ny=$Ny --od=plots/ --cell=2 --zmax=$zmax --zmin=$zmin";
	printf "\n\tDone for xp and yp!\n";
	#Movies for principal average axes
	&myline;
	printf "\tMovies for Principal Average Axes\n";
	printf "\tElectric Field\n";
#	system "$exe_3g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=principal --nem=ave --ep=e";
	system "$exe_4g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=principal --nem=ave --ep=e";
	printf "\tPolarization\n";
#	system "$exe_3g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=principal --nem=ave --ep=p";
	system "$exe_4g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=principal --nem=ave --ep=p";
      }#yes
    }#ave
    ###
    if ("$nem"eq"vsw"){
      printf "\n\tHaydock coefficients along the crystal axes for every theta\n"; 
      printf "\tRunning for $caso\n"; 
      system "$exe_principal --od=hc/ --Nh=$Nh --epsm=$mepsm --tvsw=big";
      # Fields
      if ("$fields"eq"yes"){
	my $hc="hc/$base\_$axes*\_vsw*.pld";
	if (scalar <res/*>){
	  &myline;
	  printf "\tIt seem that you have the e-fields and polarizations:\n";
	  printf "\terase the res directory if you want to run them again\n";
	  &myline;
	}
        else{
	  &myline;
	  &myline;
	  printf "\n\tFields are calculated for polarization along the principal axes for every theta\n";
	  &myline;
	  &myline;
	  system "ls $hc | $exe_fields --Nh=$Nh --od=res/ --epsa=$epsa --epsb=$epsb";
	}
	printf "\tGenerates the Efield and Polarization plots for incidence along principal axes for every theta\n";
	my $eb;
	($du,$eb)=split('epsb_',$nombre,2);
	my ($efxy,$efxx,$efyy,$zmax,$zmin);
	if (scalar <plots/*>){
	  &myline;
	  printf "\tIt seem that you have the plots: erase the plots directory\n";
	  printf "\tif you want to run them again\n";
	  &myline;
	}
        else{
	  printf "\tElectric Fields\n";
	  # first obtain the zmax and zmin of both xp and yp
	  $efxy="e-$base\_$axes*vsw*\_Nh\_$Nh\_epsa_*\_epsb\_$eb*-dat";
	  system "ls res/$efxy | sort -tW -n -k 2 | $exe_maxmin -gogo=yes";
	  # read Zmax and Zmin of both xp and yp
	  $zmax=`awk '{print \$1}' .maxmin`;
	  $zmax=~s/\s+//g;
	  $zmin=`awk '{print \$2}' .maxmin`;
	  $zmin=~s/\s+//g;
	  $zmax/=$sfcm;
	  $zmin*=$sfcm;
	  die "Can't open .emaxmin" unless open(OUTPUTa, "> .emaxmin");
	  print OUTPUTa "$zmax $zmin";
	  #	printf "\tZmin=$zmin Zmax=$zmax\n";
	  # now, the plots
	  $efxx="e-$base\_$axes*vsw*\_Nh\_$Nh\_epsa_*\_epsb\_$eb*xp-dat";
	  $efyy="e-$base\_$axes*vsw*\_Nh\_$Nh\_epsa_*\_epsb\_$eb*yp-dat";
	  system "ls res/$efxx | sort -tW -n -k 2 | $exe_plots -Nx=$Nx -Ny=$Ny --od=plots/ --cell=2 --zmax=$zmax --zmin=$zmin";
	  system "ls res/$efyy | sort -tW -n -k 2 | $exe_plots -Nx=$Nx -Ny=$Ny --od=plots/ --cell=2 --zmax=$zmax --zmin=$zmin";
	  printf "\n\tDone for xp and yp!\n";
#
	  printf "\tPolarization\n";
	  # first obtain the zmax and zmin of both xp and yp
	  $efxy="p-$base\_$axes*vsw*\_Nh\_$Nh\_epsa_*\_epsb\_$eb*-dat";
	  system "ls res/$efxy | sort -tW -n -k 2 | $exe_maxmin -gogo=yes";
	  # read Zmax and Zmin of both xp and yp
	  $zmax=`awk '{print \$1}' .maxmin`;
	  $zmax=~s/\s+//g;
	  $zmin=`awk '{print \$2}' .maxmin`;
	  $zmin=~s/\s+//g;
	  $zmax/=$sfcm;
	  $zmin*=$sfcm;
	  die "Can't open .pmaxmin" unless open(OUTPUTb, "> .pmaxmin");
	  print OUTPUTb "$zmax $zmin";
	  #	printf "\tZmin=$zmin Zmax=$zmax\n";
	  # now, the plots
	  $efxx="p-$base\_$axes*vsw*\_Nh\_$Nh\_epsa_*\_epsb\_$eb*xp-dat";
	  $efyy="p-$base\_$axes*vsw*\_Nh\_$Nh\_epsa_*\_epsb\_$eb*yp-dat";
	  system "ls res/$efxx | sort -tW -n -k 2 | $exe_plots -Nx=$Nx -Ny=$Ny --od=plots/ --cell=2 --zmax=$zmax --zmin=$zmin";
	  system "ls res/$efyy | sort -tW -n -k 2 | $exe_plots -Nx=$Nx -Ny=$Ny --od=plots/ --cell=2 --zmax=$zmax --zmin=$zmin";
	  printf "\n\tDone for xp and yp!\n";
	}

	#Movies for principal  axes
	printf "\tMovies for Principal Axes for every theta\n";
	printf "\tElectric Field\n";
#	system "$exe_3g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=principal --nem=vsw --ep=e";
	system "$exe_4g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=principal --nem=vsw --ep=e --keep";
	printf "\tPolarization\n";
#	system "$exe_3g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=principal --nem=vsw --ep=p";
	system "$exe_4g --od=movies/ --scale=$sca --angle=$angu --Nh=$Nh --epsa=$mate --epsb=$epsb --axes=principal --nem=vsw --ep=p --keep";
      }#yes
    }#vsw
    ###
  }#while
}#principal
######&&&& Axes=Principal &&&&END######
###################
sub mynamesub{
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

# file name if both epsilons are numbers
$nombre= sprintf 
    "Nh_${Nh}_epsa_%.3f-%.3f_epsb_%.3f-%.3f",
    $cepsa->re, $cepsa->im, $cepsb->re, $cepsb->im 
    if $nepsa and $nepsb;
# $filenames if only epsb number
$nombre= sprintf 
    "Nh_${Nh}_epsa_%s_epsb_%.3f-%.3f",
    $elementoa, $cepsb->re, $cepsb->im 
    if !$nepsa and $nepsb;
# $filenames if only epsa number
$nombre= sprintf 
    "Nh_${Nh}_epsa_%.3f-%.3f_epsb_%s",
    $cepsa->re, $cepsa->im, $elementob 
    if $nepsa and !$nepsb;
# $filenames if neither number
$nombre= sprintf 
    "Nh_${Nh}_epsa_%s_epsb_%s",
    $elementoa, $elementob
    if !$nepsa and !$nepsb;
}
#
sub stringtocomplex {
    my $str=shift @_;
    my($re, $im, $si)=(undef,undef,'+');
    ($re,$im, $si)=($str,0, '+') if looks_like_number($str);
#    ($re,$im)=split('i',$str,2) unless looks_like_number($str);
    ($re, $im, $si)=($1,$3, $2) if $str=~/(.*)([+-])i\*(.*)/ &&
	looks_like_number($1) && looks_like_number($3);   
    $im=-$im if $si eq '-';
    return my $cmplx=$re+i*$im if defined $re and defined $im;
    return undef;
}

sub myline {
printf "\t*************************\n";}

__END__
    
