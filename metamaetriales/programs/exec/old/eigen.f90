!!! Takes meps/eps-* out file and calculates the principal directions
!!! continuous 
!!! ifort -o reigen  eigen.f90
program continuous
  IMPLICIT NONE
  INTEGER, PARAMETER :: DP = KIND(1.d0) 
  REAL(DP), allocatable :: w(:),epsxxr(:),epsxxi(:),epsyyr(:),epsyyi(:),epsxyr(:),epsxyi(:),epsndr(:)
  REAL(DP), allocatable :: epsndi(:),epsar(:),epsai(:),epsbr(:),epsbi(:) 
  REAL(DP), allocatable :: pvr(:,:), pvi(:,:), vxr(:,:), vxi(:,:), vyr(:,:),vyi(:,:)
  REAL(DP), allocatable :: tetr(:,:), teti(:,:), nir(:,:)
  REAL(DP), allocatable :: a(:,:), b(:,:)
  COMPLEX(DP) :: ci,cexx,ceyy,cexy,det,tr,lam1,lam2
  COMPLEX(DP) :: v1x,v1y,v2x,v2y
  REAL(DP) :: signo,s1,s2
  REAL(DP) :: n1,n2
  INTEGER :: i,j,n,ndata,k(20)
!!! read data
  read(*,*)ndata
!!!
  ALLOCATE(w(ndata),epsxxr(ndata),epsxxi(ndata),epsyyr(ndata),epsyyi(ndata))
  ALLOCATE(epsxyr(ndata),epsxyi(ndata),epsndr(ndata),epsndi(ndata))
  ALLOCATE(epsar(ndata),epsai(ndata),epsbr(ndata),epsbi(ndata))
  ALLOCATE(pvr(2,ndata), pvi(2,ndata), vxr(2,ndata), vxi(2,ndata), vyr(2,ndata),vyi(2,ndata))
  ALLOCATE(tetr(2,ndata), teti(2,ndata), nir(2,ndata))
  ALLOCATE(a(2,ndata), b(2,ndata))
!!! reads input data
!!  reads the firs line
  ci=cmplx(0,1)
  read(1,*)
  do i=1,ndata
     read(1,*)w(i),epsxxr(i),epsxxi(i),epsyyr(i),epsyyi(i) &
     ,epsxyr(i),epsxyi(i),epsndr(i),epsndi(i) &
     ,pvr(1,i), pvi(1,i) &
     ,pvr(2,i), pvi(2,i) &
     ,vxr(1,i), vxi(1,i), vyr(1,i),vyi(1,i) &
     ,vxr(2,i), vxi(2,i), vyr(2,i),vyi(2,i) &
     ,tetr(1,i), teti(1,i) &
     ,tetr(2,i), teti(2,i) &
     ,nir(1,i) &
     ,nir(2,i) &
     ,epsar(i),epsai(i),epsbr(i),epsbi(i) & 
     ,a(1,i), b(1,i) &
     ,a(2,i), b(2,i)
  end do
! writes the header
  write(2,70)'w epsxxr epsxxi epsyyr epsyyi epsxyr epsxyi epsndr epsndi pv1r pv1i pv2r pv2i v1xr v1xi v1yr v1yi v2xr v2xi v2yr v2yi tet1r tet1i tet2r tet2i nir1 nir2 epsar epsai epsbr epsbi a1 b1 a2 b2'
  do i=1,ndata
     cexx=epsxxr(i)+ci*epsxxi(i)
     ceyy=epsyyr(i)+ci*epsyyi(i)
     cexy=epsxyr(i)+ci*epsxyi(i)
     tr=cexx+ceyy
     det=cexx*ceyy-cexy**2
     lam1=(tr+sqrt(tr**2-4.*det))/2.
     lam2=(tr-sqrt(tr**2-4.*det))/2.
     n1=sqrt(abs(cexy)**2+abs(lam1-cexx)**2)
     n2=sqrt(abs(cexy)**2+abs(lam2-cexx)**2)
     v1x=cexy/n1
     v1y=(lam1-cexx)/n1
     v2x=cexy/n2
     v2y=(lam2-cexx)/n2
     write(3,69)w(i),real(v1x),aimag(v1x),real(v1y),aimag(v1y),real(v2x),aimag(v2x),real(v2y),aimag(v2y)
  end do
!!$     write(*,*)i,'write in 1,2 order'
!!$     write(2,69)w(i),epsxxr(i),epsxxi(i),epsyyr(i),epsyyi(i) &
!!$          ,epsxyr(i),epsxyi(i),epsndr(i),epsndi(i) &
!!$          ,pvr(1,i), pvi(1,i) &
!!$          ,pvr(2,i), pvi(2,i) &
!!$          ,vxr(1,i), vxi(1,i), vyr(1,i),vyi(1,i) &
!!$          ,vxr(2,i), vxi(2,i), vyr(2,i),vyi(2,i) &
!!$          ,tetr(1,i), teti(1,i) &
!!$          ,tetr(2,i), teti(2,i) &
!!$          ,nir(1,i) &
!!$          ,nir(2,i) &
!!$          ,epsar(i),epsai(i),epsbr(i),epsbi(i) & 
!!$          ,a(1,i), b(1,i) &
!!$          ,a(2,i), b(2,i)
69 format(35e15.5)
70 format(35a)
end program continuous
real (KIND(1.d0))  function signo(x,y)
  INTEGER, PARAMETER :: DP = KIND(1.d0) 
  REAL(DP) :: x,y
  signo=abs(sign(1.,x)-sign(1.,y))
end function signo

