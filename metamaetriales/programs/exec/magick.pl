#!/usr/bin/env perl

#### how to run the whole enchilada
#
# Warning: convert file.png -monochrome fileBW.png
#          file fileBW.png should give:    
#          fileBW.png: PNG image data, Nx x Ny, 1-bit grayscale, non-interlaced
#                                      this values depend on the number of pixels
#           mkdir ucell cases
#
# programs in: /Users/bms/research/metamaterials/haydock/fields/programs/
#
# all of the  steps  are in ~/programs/2torial/text/how-to-run.tex
####
#BEGIN {
#push @INC,
#"/Library/Perl/5.8.6/darwin-thread-multi-2level/"};
####
use strict;
use Pod::Usage;
use Getopt::Long;
use File::Basename;
use File::Temp qw /tempfile/;
use PDL;
use PDL::IO::Pic;

# Options
my $ifn; # original file name
my $od; #output directory/prefix
my $is; # initial scaling
my $fs; #final scaling
my $ns; #number of scales
my $ia; #initial angle
my $fa; #final angle
my $na; #number of angles
my $keep=0; #keep temporal files
my $helpflag; #help
my $angle;
my $scale;
my $despulga;

pod2usage unless GetOptions(
			    "ifn=s"=>\$ifn,
			    "od=s"=>\$od,
			    "is=f"=>\$is,
			    "fs=f"=>\$fs,
			    "ns=i"=>\$ns,
			    "ia=f"=>\$ia,
			    "fa=f"=>\$fa,
			    "na=i"=>\$na,
			    "keep"=>\$keep,
			    "despulga"=>\$despulga,
			    "help|?"=>\$helpflag,
			   ) and !$helpflag and defined $ifn and defined $od and defined $is
  and defined $fs and defined $ns and defined $ia and defined $fa
  and defined $na;

die "Can't do negative number of iterations" if $ns<0 or $na<0;

my ($base, $dir, $ext)=fileparse($ifn, ".png");

$ext=".png" unless defined $ext;
my $original="$dir$base$ext";
die "File not readable: $original" unless -r $original;

chomp(my $tmp=`identify -format %h:%w $original`);
my ($originalheight, $originalwidth)=split /:/, $tmp;

foreach my $cs (0..$ns){
  $scale=$is+$cs*($fs-$is)/$ns if $ns>0;
  $scale=$is if $ns==0;
  my $scalepc = 100*$scale;
  foreach my $ca(0..$na){
    $angle=$ia+$ca*($fa-$ia)/$na if $na>0;
    $angle=$ia if $na==0;
    # operate on original figure
    (undef,my $tmp1)=tempfile(
			      sprintf("remSR_%.1f-%.2f-XXXXXX",$angle, $scale),
			      OPEN => 1, SUFFIX=>".png");
    # modify unit cell
    # despulga
    printf "\tconvert  -background none -transparent white -resize $scalepc\% -rotate $angle -gravity Center $original $tmp1\n" unless ! $despulga;
    #
    system "convert  -background none -transparent white "
      . " -resize $scalepc\% -rotate "
	. "$angle -gravity Center $original $tmp1";
    # new unit cell must be contained in old unit cell
    # get size of converted figure 
    chomp($tmp=`identify -format %h:%w $tmp1`);
    my ($height, $width)= split /:/, $tmp;
    my ($maxwidth,$maxheight)=($originalwidth, $originalheight);
    $maxheight=$height if $height>$maxheight;
    $maxwidth=$width if $width>$maxwidth;
    (undef,my $tmp2)=tempfile(
			      sprintf("remRS_%.1f-%.2f-XXXXXX",$angle, $scale),
			      OPEN=>1, SUFFIX=>".png");

### the -extent does not work with mac!!
#    system "convert -background none -gravity Center " 
#      . " -extent ${maxheight}x${maxwidth} $tmp1 $tmp2";
    # tile new unit cell with period determined by old cell
    my $shiftx=int(($maxwidth-$originalwidth)/2);
    my $shifty=int(($maxheight-$originalheight)/2);
### unit cells are correctly tiled
    my $offset="-$shiftx-$shifty";
###
### this works like a charm!
    # despulga
    printf "\tconvert -background none -gravity Center $tmp1 hoy.png\n" unless ! $despulga;
    #
    system "convert -background none -gravity Center " 
      . " $tmp1 hoy.png";
    chomp($tmp=`identify -format %h:%w hoy.png`);
    my ($bheight, $bwidth)= split /:/, $tmp;
    my ($bmaxwidth,$bmaxheight)=($originalwidth,$originalheight);
    my $bshiftx=int((-$bwidth+$originalwidth)/2);
    my $bshifty=int((-$bheight+$originalheight)/2);
    my $setoff="+$bshiftx+$bshifty";
### this works if scaling is >= 100%
    # despulga
    printf "\tbt convert -gravity center -page ${maxwidth}x${maxheight} hoy.png $tmp2\n" unless $scale<1 or  ! $despulga;
    #
    system "convert -gravity center -page ${maxwidth}x${maxheight} hoy.png $tmp2" unless $scale<1; 
### this seems to work better if scaling is < 100%
### first: creates the ucell of the original size
    # despulga
    printf "\tlt convert -size ${maxwidth}x${maxheight} xc:white $tmp2\n" unless $scale>=1 or ! $despulga;
    #
    system   "convert -size ${maxwidth}x${maxheight} xc:white $tmp2" unless $scale>=1;
### then overlays the inclusion
    # despulga
    printf "\tlt composite -gravity center  hoy.png $tmp2 $tmp2\n" unless $scale>=1 or ! $despulga;
    #
    system "composite -gravity center  hoy.png $tmp2 $tmp2" unless $scale>=1;
###
    system "rm hoy.png";
###
    my $f=$tmp2;
    (undef, my $tmp3)=tempfile(
			       sprintf("remTL_%.1f-%.2f-XXXXXX",$angle, $scale),
			       OPEN=>1, SUFFIX=>".png");
    # despulga
    printf "\tmontage -background none $f $f $f $f $f $f $f $f $f -tile x3 -geometry ${maxwidth}x${maxheight} -geometry $offset $tmp3\n" unless ! $despulga;
    # 
    system "montage -background none $f $f $f $f $f "
      . "$f $f $f $f -tile x3 "
	. " -geometry ${maxwidth}x${maxheight} "
	  . " -geometry $offset $tmp3";
    # crop lattice to get possibly overlapped unit cell
    (undef, my $tmp4)=tempfile(
			       sprintf("remCR_%.1f-%.2f-XXXXXX",$angle, $scale),
			       OPEN=>1, SUFFIX=>".png");
### this works if scaling is >= 100%
    # despulga
    printf "\tbt convert $tmp3 -gravity Center -crop ${originalwidth}x${originalheight}+0+0 $tmp4\n" unless $scale<1 or ! $despulga;
    #
    system "convert $tmp3 -gravity Center "
      . " -crop ${originalwidth}x${originalheight}+0+0 "
	. "$tmp4" unless $scale<1;
### this works if scaling is < 100%
    # despulga
    printf "\tlt convert $tmp3 -gravity Center -crop ${originalwidth}x${originalheight}+0+0 $tmp4\n" unless $scale>=1 or ! $despulga;
    #
    system "convert $tmp3 -gravity Center "
      . " -crop ${originalwidth}x${originalheight}+0+0 "
	. "$tmp4" unless $scale>=1;
    # make final tile for beautiful illustrations
    (undef, my $tmp5)=tempfile(
			       sprintf("remFTL_%.1f-%.2f-XXXXXX",$angle, $scale),
			       OPEN=>1, SUFFIX=>".png");
    $f=$tmp4;
    printf "\tmontage $f $f $f $f $f $f $f $f $f -tile x3 -geometry ${originalwidth}x${originalheight} $tmp5\n" unless ! $despulga;
    system "montage $f $f $f $f $f $f $f $f $f -tile x3 -geometry ${originalwidth}x${originalheight} $tmp5";
    #set name
    my $bout=sprintf "ucell/${base}_A%.2f_S%.3f${ext}",$angle, $scale;
    die "Can't create $bout" unless rename($tmp5,$bout);
# for scale > 1
    system "convert -size ${originalwidth}x${originalheight}+0+0 xc:white chin.png" unless $scale<1;
    system "composite -gravity center  $tmp4 chin.png chin.png" unless $scale<1;
    system "mv chin.png $tmp4" unless $scale<1;
#
    #
    # get actual filling fraction (might be less than scaled
    # filling fraction due to overlap)
    my $im=rpic $tmp4; #read image
    #	my $im = $im ==0;
    $im = $im ==0;
    my $Nel=pdl($im->dims);
    my $ff=$im->sum/$Nel->prodover; #filling fraction.
    #set name
    my $out=sprintf "${od}${base}_A%.2f_S%.3f_f%.3f${ext}",
      $angle, $scale, $ff;
    die "Can't create $out" unless rename($tmp4,$out);
    print STDERR "Scale=$scale Teta=$angle, f=$ff \n";
    map {die "couldn't delete temporary file: $_" unless unlink $_} 
      ($tmp1, $tmp2, $tmp3) unless $keep;
  }
}

__END__

=head1 SYNOPSIS

./magick.pl --ifn=<input image file> --od=<output dir> --is=<number> --fs=<number>  \
            --ns=<number> --ia=<number> --fa=<number> --na=<number> --keep
   

     Generate unit cells of arbitrary rectangular tilings of an arbitrary
     png figure given as input after given rotations and scalings.
     The input figure must be in black and white/alpha  with black representing
     inclusions and with a transparent background (important).

     --ifn=<name>   Input image file name of type png
                    Note: The output filenames are built from the input
                    image name by appending the filling fraction of the
                    resulting structure and the rotation angle.
     --od=<name>    Directory name where all output files will be dropped

     --is=<number>  Initial scaling (1 means original scale)
     --fs=<number>  Final scale
     --ns=<number>  Number (non-negative) of scale steps.

     --ia=<number>  Initial counterclockwise angle (0 means original
                    orientation) 
     --fa=<number>  Final angle
     --na=<number>  Number (non-negative) of angle steps.

     --keep         Keep temporary files, maybe for illustrations. The 
                    temporary files are named remSR... for scaled and 
                    rotated, remRS... for rescaled to no smaller than 
                    original scale, remTL... for remRS... tiled, remCR.. 
                    for remRS cropped to original size and remFTL for remCR 
                    tilled to illustrate actual lattice.
     --despulga     writes the commands that are run

The input image could be produced with inkscape. 
    1. The picture size in pixels corresponds to the real and
       reciprocal space grid in the Haydock calculation. The size can
       be set with the menu File/Document Properties/Custom size
    2. The background should be white/opaque, as could be obtained
       using the menu File/Document Properties/ (use R:255 G:255 B:255 A:255)
    3. The particles should be black (corresponding to $\epsilon_b$ in
       our theory).
    4. To obtain the png file the image may be exported with
       File/Export bitmap choose Page

=cut


