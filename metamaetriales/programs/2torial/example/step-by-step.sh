# creates directories
mkdir cases ucell hc res meps plots movies arrows rt
# runs magick.pl
../../exec/magick.pl --ifn=cross.png --od=cases/ --is=1 --fs=1 --ns=0 --ia=0 --fa=45 --na=9
# the-whole-enchilada.pl
../../exec/the-whole-enchilada.pl --Nh=50 -epsa=eps_ag.dat --epsb=1.01 --nem=vsw --case=cases/cross_A* --cual=ronly
# tochito.sh
tochito.sh
