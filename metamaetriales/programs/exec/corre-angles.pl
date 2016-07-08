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
my $exec="$ruta/angarr.pl";
my $exec_eli="$ruta/elipses.pl";
my $execawk="$ruta/chose-column.awk";
# reads input
# Options
my $idf; #file name 
my $od; #output directory
my $tam; #help
my ($ht1,$ht2);
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

corre-angles.pl --od=s --idf=s --tam=f 

             s=>string f=>real 

    Generate plots with arrows following the PV angles spectrum

    --od=path         output directory 
    --idf=path        meps/eps-*-dat 
    --tam=f           size of the arrows

FIN
unless defined $od and defined $idf and defined $tam;

#
# Extract the name
my ($fcase, $id, $ext)=fileparse($idf, "-dat");
#
printf "\n";
printf "\tExtracting frequency aa1 aa2 a(1,2) b(1,2) for arrows\n";
system "awk -f $execawk -v colname=w $idf > w.rem";
system "awk -f $execawk -v colname=aa1 $idf > 1.rem";
system "awk -f $execawk -v colname=aa2 $idf > 2.rem";
system "awk -f $execawk -v colname=a1 $idf > 3.rem";
system "awk -f $execawk -v colname=b1 $idf > 4.rem";
system "awk -f $execawk -v colname=a2 $idf > 5.rem";
system "awk -f $execawk -v colname=b2 $idf > 6.rem";
system "awk -f $execawk -v colname=ht1 $idf > 7.rem";
system "awk -f $execawk -v colname=ht2 $idf > 8.rem";
system "paste w.rem 1.rem 2.rem 3.rem 4.rem 5.rem 6.rem 7.rem 8.rem > gata.dat";
system "rm *.rem";
printf "\tDone\n";
my $NL=0;
$NL=`wc gata.dat | awk '{print \$1}'`;
$NL=($NL+0);# chafaldrana way to remove white space, since I don't have trim
my $case="gata.dat";
    open(FILE, "< $case");
    my $n=0;
    while(<FILE>){
    chomp;
    $n=($n+1);
    my ($frec, $t1, $t2, $a1, $b1, $a2, $b2, $ht1, $ht2)=split;
    $frec=sprintf "%.4f",$frec;
# eta(1,2)
    my $eta1=($a1-$b1)/($a1+$b1);
    my $eta2=($a2-$b2)/($a2+$b2);
# t1,eta1,eta2
    $t1=sprintf "%.2f",$t1;
    $t2=sprintf "%.2f",$t2;
    $eta1=sprintf "%.2f",$eta1;
    $eta2=sprintf "%.2f",$eta2;
#
    printf "\teta $n of $NL for $frec eV\n";
    system "$exec --od=$od --idf=$idf --tag=$n --tam=$tam --a1x=$frec --a1y=$t1 --a2x=$frec --a2y=$t2 --a3x=$frec --a3y=$eta1 --a4x=$frec --a4y=$eta2 --ht1=$ht1 --ht2=$ht2";
    printf "\tEllipse $n of $NL for $frec eV\n";
    system "$exec_eli --od=$od --idf=$idf --tag=$n --frec=$frec --a1=$a1 --b1=$b1 --a2=$a2 --b2=$b2 --t1=$t1 --t2=$t2 --ht1=$ht1 --ht2=$ht2";
    }
printf "\tDone!\n";
system "rm gata.dat";
__END__
