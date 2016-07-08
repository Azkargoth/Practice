#!/usr/bin/env perl
#######################
use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use File::Basename;
use Cwd;
#
my $gogo;
#
GetOptions(
    "gogo=s"=>\$gogo,
    );
die <<"FIN"
ls path/(e,p)-*-dat | sort -t[A,S,W] -n -k 2 | path/max-min.pl --gogo=s
  
                  sort A(angles), S(scale) or W(energy) 
                  s=>string

 Obtains the Max and Min values 
    
 (e,p)-*-dat are the files with the electric fields or 
             polarization for x and y external E-field

    --gogo=s          yes=>run or no=>help

FIN
unless defined $gogo;

my $nname;
my $cont=0;

my @files;
while(<>){
    chomp;
    push @files, $_;
}

#Get absolute max and min over all files:
printf "\n\tObtaining Zmax and Zmin\n"; 
my ($zmax, $zmin);
my $NL=0;
foreach my $case(@files){
    open(FILE, "< $case");
    while(<FILE>){
	my @numbers=split;
	$zmax=max($numbers[2], $zmax);
	$zmin=min($numbers[2], $zmin);
    }
    $NL=($NL+1);
}

printf "\tZmax=$zmax and Zmin=$zmin\n"; 
printf "\tDone!\n";
die "Can't open .maxmin" unless open(OUTPUT, "> .maxmin");
print OUTPUT "$zmax $zmin";

sub max {
    my $a=shift;
    my $b=shift;
    return $a unless defined $b;
    return $b unless defined $a;
    return $a if $a>$b;
    return $b;
}
    
sub min {
    my $a=shift;
    my $b=shift;
    return $a unless defined $b;
    return $b unless defined $a;
    return $a if $a<$b;
    return $b;
}

__END__

=head1 SYNOPSIS


=cut
