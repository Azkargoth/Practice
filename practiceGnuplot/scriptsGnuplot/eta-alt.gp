set terminal epslatex color colortext dashed standalone

set xlabel "{\\Large Photon Energy (eV)}"


set xtics 0.25 nomirror
set ytics nomirror

#z lenght of layer [Angstroms (la) & meters (lm)]
lb=5.564770163
la=2.944749766
lm=la*1E-10

set zeroaxis lw 1 lt 2 lc 0
#set label "{\\Large C$_{16}$H$_{8}$-alt}"   at  graph 0.8, graph 0.9 


#######   THREE IN ONE PLOT 
set xrange [0.7:1.6]
#set yrange [-6:5]

set key title "Component"

set ylabel "{{\\Large $\\eta^{axy}(\\omega)$} {\\small $[\\times 10^{10}]$}}"
#set key left bottom
set output "eta-alt.tex"
p   "../res/calEta2.kk_xxy_yxy_zxy_14452_1_65-nospin2_scissor_0_Nc_41" u 1:($2/1E+10) title "x" w l ls 1 lw 2 lt 1,\
	"../res/calEta2.kk_xxy_yxy_zxy_14452_1_65-nospin2_scissor_0_Nc_41" u 1:($3/1E+10) title "y" w l ls 2 lw 3 lt 2,\
	"../res/calEta2.kk_xxy_yxy_zxy_14452_1_65-nospin2_scissor_0_Nc_41" u 1:($4/1E+10) title "z" w l ls 3 lw 3 lt 3
