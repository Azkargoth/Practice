#!/usr/bin/perl
 use File::Basename;
 use Cwd;
 use File::Copy;
 use Term::ANSIColor;
 ##SOURCE =================== 
    my @information;
    my @VALIDFILES;
    if ((@ARGV=~0)){
	print "\t Usage: checkGNUPLOTg.pl [namefile.g] \n" ;
	die;
    }
    $INFOABINIT=$ARGV[0];
    my $char = '#';
    if (-e "$INFOABINIT")
       {
           print "  $INFOABINIT exist ... \n";
       }
       else {
           print color 'red';
           print "not FILE=$INFOABINIT \n";
           print "Make one... \n";
           print color 'reset';
          die ;
             }


     open(INFOABINIT) or die("Could not open $INFOABINIT file.");
          {
     foreach $line (<INFOABINIT>) {
     my $result = index($line, $char);
     $vari = substr($line, 0, $result);
  
     if (($vari !~ /[\#]/)) {
        chomp($vari);             
          push @information, $vari;
                                 } #end if
                                } #end foreach
                               } #end open

         
          $lenpp=@information;
           for ($i=0; $i<$lenpp; $i++)
             {
             $CADENA=($information[$i]);

           if (($CADENA =~ m/\'/) && ($CADENA !~ m/set/)){
             my $offset=0;
             my $LOOKFOR = '\'';
             my $LIMINF=index($CADENA, $LOOKFOR, $offset);
             $offset = $LIMINF+1;
             my $LIMSUP=index($CADENA, $LOOKFOR, $offset);
             $DELTA=$LIMSUP-$LIMINF;  
             $ARCHIVO=substr($CADENA, ($LIMINF+1), $DELTA-1);
             #print "$ARCHIVO \n"
             push @VALIDFILES, $ARCHIVO;
	     }
	 }
            
##================================
              $LEN=@VALIDFILES;
               for ($i=0; $i<$LEN; $i++){
                   $FILEV=($VALIDFILES[$i]);
		   $ii=$i+1;
                 if (-e $FILEV) {
		   print " $ii   $FILEV [";
                   print color 'green';
                   print "ok exists";
                   print color 'reset';
                   print "]\n";
		   } else {
		   print " $ii   $FILEV [";
                   print color 'red';
                   print "NOT exists";
                   print color 'reset';
                   print "]\n"; 
                   system('touch errorPLOTLINE');
		 }
	    } ##for
printf "\n";
                 
