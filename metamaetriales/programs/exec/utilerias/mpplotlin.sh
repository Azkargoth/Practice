#!/bin/bash
##
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m' # No Color
## reads the path to find the executables
ruta=`awk '{print $1}' .ruta`
ruta="$ruta/utilerias"
##
function Line {
    printf "\t${BLUE}=============================${NC}\n"
}
##
if [ "$#" -eq 0 ]
    then   # Script needs at least one command-line argument.
    Line
    printf  ${blue}"\tUsage::\n"
    printf  ${BLUE}"\tmpplotlin.sh ${RED}file${NC} ${red}scale${NC} [${red}1-view,2-batch${NC}]\n"
#    printf  ${red}"\t$ruta\n"
Line
exit 1
fi
if [ ! "$#" -eq 0 ]
then
cual=$3
INPUTFILE=$1
  if [ -e $INPUTFILE ];then
   TRUEFILE=$INPUTFILE
  fi
  if [ -e $INPUTFILE.g ];then
   TRUEFILE=$INPUTFILE.g
  fi 
  if [ -e $INPUTFILE"g" ];then
   TRUEFILE=$INPUTFILE"g"
  fi
##=========================================
if [ ! -e $INPUTFILE.g  ] && [ ! -e $INPUTFILE ] && [ ! -e $INPUTFILE"g" ] ;then      
    
    if [[ "$INPUTFILE" == *"g"  ]];then
             
         if [[ "$INPUTFILE" == *".g"  ]];then
             printf "\t${CYAN}There is not file:${NC} $INPUTFILE \n"  
         else 
             printf "\t${CYAN}There is not file:${NC} $INPUTFILE"g" \n"
         fi
    else 
       if [[ "$INPUTFILE" == *"."  ]];then
        printf "\t${CYAN}There is not file:${NC} $INPUTFILE"g" \n"
       else
        printf "\t${CYAN}There is not file:${NC} $INPUTFILE.g \n"
       fi 
    fi  
    printf "\t${RED}Stoping right now ...${NC}\n"
exit 1
fi
### checks if files exist
f=${TRUEFILE%%.g}
#echo $TRUEFILE $INPUTFILE $f
#exit 1
$ruta/xparserPLOTLIN.pl $f.g
### gnuplotea
gnuplot $f.g
## adds \usepackage{color}
awk '{print ($1 !~ /begin{document}/) ? $0 : "\\usepackage{color}"$0}' fig.mp > hoy1
## adds \usepackage{amssymb}
awk '{print ($1 !~ /begin{document}/) ? $0 : "\\usepackage{amssymb}"$0}' hoy1 > hoy
mv hoy fig.mp
rm hoy1
mpost --tex=latex fig.mp
### latejea
latex $ruta/figlamp
dvipdf figlamp aux.pdf
#cropea
pdfcrop aux.pdf $f.pdf
#generates *.pdf end *.eps files
$ruta/convierte_pdf2eps.sh $f
rm fig.0 fig.mp  fig.log
#rm mpx* error*
rm figlamp.* aux*
# displays
if [ $cual == "1" ]
then
    es=$2
    escala=`echo $es \* 100 |bc -l| awk -F. '{print $1}'`
    fac=`echo $es \* 450 |bc -l| awk -F. '{print $1}'`
    xpdf -g $fac -z $escala $f.pdf 
fi
#
fi
