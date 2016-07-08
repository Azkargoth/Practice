!!! Takes meps/eps-* out file and makes the principal values to be
!!! continuous 
!!! ifort -o rcontinuous-eps  continuous-eps.f90
program continuous
  IMPLICIT NONE
  INTEGER, PARAMETER :: DP = KIND(1.d0) 
  REAL(DP), allocatable :: w(:),epsxxr(:),epsxxi(:),epsyyr(:),epsyyi(:),epsxyr(:),epsxyi(:),epsndr(:)
  REAL(DP), allocatable :: epsndi(:),epsar(:),epsai(:),epsbr(:),epsbi(:) 
  REAL(DP), allocatable :: pvr(:,:), pvi(:,:), vxr(:,:), vxi(:,:), vyr(:,:),vyi(:,:)
  REAL(DP), allocatable :: tetr(:,:), teti(:,:), nir(:,:)
  REAL(DP), allocatable :: a(:,:), b(:,:)
  REAL(DP) :: signo,s1,s2
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
  n=0
  k(0)=1
  do i=1,ndata-1
     s1=signo(abs(tetr(1,i))-45,abs(tetr(1,i+1))-45)
     s2=signo(abs(tetr(2,i))-45,abs(tetr(2,i+1))-45)
     if((s1.ne.0).and.(s2.ne.0)) then
        n=n+1  !add the number of sing changes
        k(n)=i !place of the sign change
     end if
     k(n+1)=ndata
  end do
  do j=1,n+1
     do i=k(j-1)+1,k(j)
        if(mod(j,2).eq.1) then
           write(*,*)i,'write in 1,2 order'
           write(2,69)w(i),epsxxr(i),epsxxi(i),epsyyr(i),epsyyi(i) &
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
        end if
        if(mod(j,2).eq.0) then
           write(*,*)i,'write in 2,1 order'
           write(2,69)w(i),epsxxr(i),epsxxi(i),epsyyr(i),epsyyi(i) &
                ,epsxyr(i),epsxyi(i),epsndr(i),epsndi(i) &
                ,pvr(2,i), pvi(2,i) &
                ,pvr(1,i), pvi(1,i) &
                ,vxr(2,i), vxi(2,i), vyr(2,i),vyi(2,i) &
                ,vxr(1,i), vxi(1,i), vyr(1,i),vyi(1,i) &
                ,tetr(2,i), teti(2,i) &
                ,tetr(1,i), teti(1,i) &
                ,nir(2,i) &
                ,nir(1,i) &
                ,epsar(i),epsai(i),epsbr(i),epsbi(i) & 
                ,a(2,i), b(2,i) &
                ,a(1,i), b(1,i)
        end if
     end do
  end do
69 format(35e15.5)
70 format(35a)
end program continuous
real (KIND(1.d0))  function signo(x,y)
  INTEGER, PARAMETER :: DP = KIND(1.d0) 
  REAL(DP) :: x,y
  signo=abs(sign(1.,x)-sign(1.,y))
end function signo

