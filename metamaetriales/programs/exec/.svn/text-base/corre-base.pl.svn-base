#!/usr/bin/env perl
#######################
# usage
# chose a set of B&W figures (unit cells) with ls, i.e.
# ls elipse*S1.20*
# run with
# ls  path1/elipse*S1.20* | path2/fields/programs/corre-base.pl (follow instructions)
#######################

use strict;
use Pod::Usage;
use Getopt::Long;
use File::Basename;
use Cwd;
# Reads input
my $Nh; # number of Haydock coefficients
my $ifn; #file name 
my $od; #output directory
my $helpflag; #help
#
pod2usage unless GetOptions(
    "Nh=i" => \$Nh, 
    "od=s" => \$od,
    "help|?"=>\$helpflag,
    ) and !$helpflag and defined $Nh and defined $od; 

# program to run
#path where the programs are located in your computer
#read from PWD/.ruta
my $ruta=`awk '{print \$1}' .ruta`;
$ruta=~s/\s+//g;
my $haydock="$ruta/haydock2DNRBase.pl";
# 

while(<>){
    chomp(my $figure=$_);
    my ($base, $directory, $extension)=fileparse($figure, ".png");
    $figure="$directory$base.png";
    print "\n";
    print "\tRunning Fields for $base\n";
    print "\n";
    system "$haydock --Nh $Nh --if $figure --od $od";
}
__END__

=head1 SYNOPSIS


ls path/files*.png |  corre_base.pl --Nh=i --od=outputDirectory

    Calculates the Haydock Coefficients and Base a binary 2D metamaterial

    files*.png    input files (.png) with the unit cell
                  Note: include the path
                  The * is to group png files 

    --Nh=i        maximum number of Haydock coefficients
    --od=path     output directory. 
                  Note: The output filenames are built from the input
                  image name by appending the value of Nh
                  and the extension .pld 

=cut
