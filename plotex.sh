#!/bin/bash

#Reinaldo Arturo Zapata Peña
#reinaldo.zapata.p@gmail.com
#https://github.com/reinaldo-z

# To have this script workign you'll need to make it executable:
#       chmod -x plotex.sh
# and add an alias in the .bashrc file:
#       alias plotex='route/to/this/file/plotex.sh

#This script was made to make a fast compilation of one or more tex files, 
#produced by a gnuplot using the epslatex terminal.

#This script automatically reads the corresponding names from the "set output" 
#lines in the script, excludes the commented output lines and compiles the 
#produced *.tex files. Also removes the temporary files including the *.tex 
#produced by gnuplot.

#To use it only type in the pwd:
#   plotex <filename_to_gnuplot>  (to compile in regular mode)
#   plotex -q <filename_to_gnuplot>  (to compile in quiet mode)

if [ -z "$1" ]; then
    echo -e "\tUsage: \n\t\tplotex <filename_of_gnuplot_script>"
    echo -e "\t\tplotex -q <filename_of_gnuplot_script> (to compile in quiet mode)\n"
    exit 1
elif [ "$1" = "-q" ]; then
    if [ -z "$2" ]; then
        echo -e "\tUsage: \n\t\tplotex <filename_of_gnuplot_script>"
        echo -e "\t\tplotex -q <filename_of_gnuplot_script> (to compile in quiet mode)\n"
        exit 1
    else
        gnuplot "$2" 
        texfiles=(`grep output "$2" | grep -v \# |awk -F"\"" '{for(i=2;i<=NF;i+=2)print $i}'`)
        for i in "${texfiles[@]}"; do
            # echo "$i exist"
            echo -e "Compiling: $i"
            pdflatex "$i" >/dev/null
            rm "${i//.tex}"-inc-eps-converted-to.pdf
            rm "${i//.tex}"-inc.eps
            rm "${i//.tex}".aux
            rm "${i//.tex}".log
            rm "$i"
        done
    fi
else
    gnuplot "$1" 
    texfiles=(`grep output "$1" | grep -v \# |awk -F"\"" '{for(i=2;i<=NF;i+=2)print $i}'`)
    for i in "${texfiles[@]}"; do
        # echo "$i exist"
        pdflatex "$i"
        rm "${i//.tex}"-inc-eps-converted-to.pdf
        rm "${i//.tex}"-inc.eps
        rm "${i//.tex}".aux
        rm "${i//.tex}".log
        rm "$i"
    done
fi
