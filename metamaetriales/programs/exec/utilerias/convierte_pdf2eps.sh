#!/bin/bash
##
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m' # No Color
##
function Line {
printf "\t${blue}--------------------------------------${NC}\n"
}
##
if [ "$#" -eq 0 ]
    then   # Script needs at least one command-line argument.
    Line
    printf "\tUsage:\n"
    printf "\tconvierte.sh ${RED}file${NC} (no extensions)\n"
    Line
exit 1
fi
if [ ! "$#" -eq 0 ]
then
###
    archivo=$1
### for ps files
    if [ -e $archivo.pdf ]
    then
	pdftops -eps $archivo.pdf
	Line
	printf  ${BLUE}"\toutput: $archivo.eps & $archivo.pdf\n"
	Line
    fi
###

fi
