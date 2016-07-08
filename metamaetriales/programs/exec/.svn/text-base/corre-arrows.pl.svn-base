#!/usr/bin/env perl
#######################

use strict;
use Pod::Usage;
use Getopt::Long;
use File::Basename;
use Cwd;
#
#programas a correr
my $ruta=`awk '{print \$1}' .ruta`;
$ruta=~s/\s+//g;
my $exec="$ruta/arrows.pl";
my $execawk="$ruta/chose-column.awk";
# reads input
# Options
my $idf; #file name 
my $od; #output directory
my $tam; #help
#
GetOptions(
    "od=s" => \$od,
    "idf=s" => \$idf,
    "tam=f" => \$tam,
    );
#
# screen instructions
#
die <<"FIN"

corre-arrows.pl --od=s --idf=s --tam=f 

             s=>string f=>real 

    Generate plots with arrows following the Reflectance spectrum

    --od=path         output directory 
    --idf=path        path/input-file 
    --tam=f           size of the arrows

FIN
unless defined $od and defined $idf and defined $tam;

#
# Extract the name
my ($fcase, $id, $ext)=fileparse($idf, "-dat");
#
printf "\n";
printf "\tExtracting frequency Rx Ry for arrows\n";
system "awk -f $execawk -v colname=w $idf > w.rem";
system "awk -f $execawk -v colname=nir1 $idf > 1.rem";
system "awk -f $execawk -v colname=nir2 $idf > 2.rem";
system "paste w.rem 1.rem 2.rem > gato.dat";
system "rm w.rem 1.rem 2.rem";
printf "\tDone\n";
my $NL=0;
$NL=`wc gato.dat | awk '{print \$1}'`;
$NL=($NL+0);# chafaldrana way to remove white space, since I don't have trim
my $case="gato.dat";
    open(FILE, "< $case");
    my $n=0;
    while(<FILE>){
    chomp;
    $n=($n+1);
    my ($frec, $rx, $ry)=split;
    $frec=sprintf "%.8f",$frec;
    $rx=sprintf "%.4f",$rx;
    $ry=sprintf "%.4f",$ry;
    printf "\tplot $n of $NL for $frec eV\n";
    system "$exec --od=$od --idf=$idf --tag=$n --tam=$tam --a1x=$frec --a1y=$rx --a2x=$frec --a2y=$ry";
    }
printf "\tDone!\n";
system "rm gato.dat";
__END__




