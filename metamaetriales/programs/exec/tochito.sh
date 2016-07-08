#!/bin/bash
##
#angles=(0.00 5.00 10.00 15.00 20.00 25.00 30.00 35.00 40.00 45.00)# change as required
figure=elipse # change as required
angles=(45.00) # change as required
## --df=film thickness in nm, change as required
## --nc=refraction-index-of-medium-c, change as required
touch tmp.sh
chmod +x tmp.sh
for i in ${angles[@]}
do
    printf "\tcc=A$i fig=$figure; ls meps/eps-\$fig*\$cc*-dat-original |sort -tS -n -k 2 | ~/research/metamaterials/haydock/fields/programs/exec/plot-rt.pl --tag=\$cc --df=100 --nc=1.4\n" > tmp.sh
    tmp.sh
done
rm tmp.sh
