#!/usr/bin/gnuplot -persist
#
#    
#    	G N U P L O T
#    	Version 4.6 patchlevel 4    last modified 2013-10-02 
#    	Build System: Linux x86_64
#    
#    	Copyright (C) 1986-1993, 1998, 2004, 2007-2013
#    	Thomas Williams, Colin Kelley and many others
#    
#    	gnuplot home:     http://www.gnuplot.info
#    	faq, bugs, etc:   type "help FAQ"
#    	immediate help:   type "help"  (plot window: hit 'h')
# set terminal wxt 2
# set output
set size ratio -1 1,1
set trange [-1:1]

# parte real v1 e imaginaria v11 del eigenvector complejo de polarización
# cámbialo a tu gusto

#v1x = 1 #v'_x
#v1y = 1 #v'_y
#v11x = 0 #v''_x
#v11y = 1 #v''_y

# 1.95
#v1x=-0.679571548486837;v11x=0.589435892513409;v1y=0.436701486685659;v11y=0.00629687467389437
# 2
#v1x= -0.0265304509285826;v11x= 0.836328687163179; v1y= 0.547044969925755;v11y= 0.0243364557889744
# 2.1
v1x=0.713489639688311;v11x=0.621189110146509;v1y=0.320611726130582;v11y=0.0475893324223067
####
#v1x = 1.01 #v'_x
#v1y = 0.01 #v'_y
#v11x = 0.01 #v''_x
#v11y = 1.01 #v''_y

xx(t)=v1x*cos(t)+v11x*sin(t)
yy(t)=v1y*cos(t)+v11y*sin(t)

# Arma forma bilineal
D=(v1y*v11x-v1x*v11y)**2
Mxx = (v1y**2+v11y**2)/D
Mxy = -(v1x*v1y+v11x*v11y)/D
Myy = (v1x**2+v11x**2)/D
# Traza y Determinante
tr = Mxx+Myy
det = Mxx*Myy-Mxy**2
# eigenvalores M=+ y m=-
lm = (tr-sqrt(tr**2-4*det))/2
lM = (tr+sqrt(tr**2-4*det))/2
# semiejes
a = 1/sqrt(lm)
b = 1/sqrt(lM)
# tangente de sus direcciones
tgm=(lm-Mxx)/Mxy
tgM=(lM-Mxx)/Mxy
# cosenos y senos de sus direcciones
cM = 1/sqrt(1+tgM**2)
sM = tgM/sqrt(1+tgM**2)
cm = 1/sqrt(1+tgm**2)
sm = tgm/sqrt(1+tgm**2)

# grafica la elipse correspondiente y sus semiejes
set parametric
# m-> -, M-> +
plot xx(pi*t), yy(pi*t), a*cm*t,a*sm*t, b*cM*t,b*sM*t
#    EOF
