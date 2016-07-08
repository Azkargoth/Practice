#!/bin/bash
#casos=(40x50/s1.5/14/0.510/rt/rt-nt-1.4-140-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.501-0.000_t145 40x50/s1.5/14/0.510/rt/rt-nt-1.4-130-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.501-0.000_t145 40x50/s1.5/14/0.510/rt/rt-nt-1.4-120-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.501-0.000_t145 40x50/s1.5/14/0.510/rt/rt-nt-1.4-110-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.501-0.000_t145 40x50/s1.5/14/0.510/rt/rt-nt-1.4-100-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.501-0.000_t145 40x50/s1.5/14/0.510/rt/rt-nt-1.4-90-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.501-0.000_t145 40x50/s1.5/14/0.510/rt/rt-nt-1.4-80-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.501-0.000_t145 40x50/s1.5/14/0.510/rt/rt-nt-1.4-70-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.501-0.000_t150)

casos=(40x50/s1.5/14/0.510/rt/rt-nt-1.4-150-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.001-0.000_t143 40x50/s1.5/14/0.510/rt/rt-nt-1.4-140-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.001-0.000_t144 40x50/s1.5/14/0.510/rt/rt-nt-1.4-130-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.001-0.000_t145 40x50/s1.5/14/0.510/rt/rt-nt-1.4-120-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.001-0.000_t147 40x50/s1.5/14/0.510/rt/rt-nt-1.4-110-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.001-0.000_t149 40x50/s1.5/14/0.510/rt/rt-nt-1.4-100-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.001-0.000_t152 40x50/s1.5/14/0.510/rt/rt-nt-1.4-90-nm-cross_A0.00_S1.000_f0.510_crystal_Nh_100_epsa_ag_epsb_1.001-0.000_t155)


for i in ${casos[@]}
do
    #printf "\t$i\n"
    cp $i fort.1
    n=`wc fort.1 | awk '{print $1}'`
    echo $n | /Users/bms/research/metamaterials/haydock/fields/programs/exec/rminimum
done
rm fort.1

