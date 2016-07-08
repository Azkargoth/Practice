set term mp color solid latex magnification 1
set out 'fig.mp'
#
file='rt/rt-100-nm-cross_A45.00_S1.000_f0.473_crystal_Nh_50_epsa_ag_epsb_1.010-0.000.d'
file2='/Users/bms/meetings/15/smf/talk/tr-silver.dat'
#set size square
set xlabel '\Large $\hbar\omega$ (eV)'
set ylabel '\Large $ T,R$'
set xrange [.9:3.1] 
set yrange [-.05:1.05] 
# add ht,hr to column("helicityt") to get different colors for the transmitted or reflected helicity
ht=2
hr=2
# size of the ellipses
s = 0.1
# size of funny ellipse for the key
st = 0.001
# every energy
ev=10
# label for angle
#set label 1 at 2,.9 '\Large $\theta=0^\circ$' c
#set title '\Large cross $\alpha=45.00$ $S=1.000$ $f=0.473$ $\theta=180^\circ$' c
set title '\Large $\theta=180^\circ$' c
#
set label 2 at 1.1,.925 '\large $R$-silver'
set label 3 at 1.1,.05 '\large $T$-silver'
#
p file every ev u "w":"T":(s*column("at")):(s*column("bt")):"anglet":(column("helicityt")+ht) w ellipses units xx lc variable lt 1 t '',\
     '' every ev u "w":"R":(s*column("ar")):(s*column("br")):"angler":(column("helicityr")+hr) w ellipses units xx lc variable t '',\
     '' every ev u "w":"R":(st*column("ar")):(st*column("br")):"angler" w ellipses units xx  lt 1 lw 2 t '-1 $\circlearrowright$',\
     '' every ev u "w":"R":(st*column("ar")):(st*column("br")):"angler" w ellipses units xx  lt 3 lw 2 t '+1 $\circlearrowleft$',\
     '' u "w": "T" w l lt 4 t '\Large $T$',\
     '' u "w": "R" w l lt 2 t '\Large $R$',\
file2 u 1:2 w l lt 1 t '',\
file2 u 1:3 w l lt 1 t ''

