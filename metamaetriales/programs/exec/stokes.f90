!!!
!!!  Calculates the Stokes vector through the Mueller Matrix calculated via
!!!  the Jones matrix, according to
!!!  /Users/bms/research/metamaterials/haydock/fields/paper/mueller/jones.pdf 
!!!  With the Stokes vector, the degree of Polarization is also calculated
!!!

program stokes
  IMPLICIT NONE
  DOUBLE COMPLEX :: V(2,2), Vt(2,2),Vta(2,2),t(2,2),r(2,2)
  DOUBLE COMPLEX :: Jt(2,2),Jr(2,2),Jtd(2,2),Jrd(2,2)
  DOUBLE complex :: aux(2,2)
  DOUBLE precision :: mt(0:3,0:3),mr(0:3,0:3)
  DOUBLE COMPLEX :: sigma(0:3,2,2)
  DOUBLE precision :: St(0:3),Sr(0:3),Si(0:3)
  DOUBLE complex :: Jt1,Jt2,Jt3,Jt4
  DOUBLE complex :: Jr1,Jr2,Jr3,Jr4
  DOUBLE COMPLEX :: ci,zero,cuno
  DOUBLE precision :: w,  V1xr,  V1yr,  V1xi,  V1yi,  V2xr,  V2yr,  V2xi, V2yi
  DOUBLE precision ::    V1dxr, V1dyr, V1dxi, V1dyi, V2dxr, V2dyr, V2dxi, V2dyi
  DOUBLE precision :: r1r, r1i, r2r, r2i, t1r, t1i, t2r, t2i
  DOUBLE precision :: pi
  DOUBLE precision :: Pt,Pr,sumt,sumr,nor,vio
  INTEGER :: iw, n, i,j
  ! constants
  pi=4.*atan(1.d0)
  ci=(0.d0,1.d0)
  zero=(0.d0,0.d0)
  cuno=(1.d0,0.d0)
  !Pauli matrices plus the identity
  ! set all matrices to zero
  sigma=zero
  ! defines finite elements only 
  ! sigma_0
  sigma(0,1,1)=cuno
  sigma(0,2,2)=cuno
  ! sigma_1
  sigma(1,1,1)=cuno
  sigma(1,2,2)=-cuno
  ! sigma_2
  sigma(2,1,2)=cuno
  sigma(2,2,1)=cuno
  ! sigma_3
  sigma(3,1,2)=-ci
  sigma(3,2,1)=ci
  !
  ! reads data
  !header
  write(3,*)"w St0 St1 St2 St3 Sr0 Sr1 Sr2 Sr3"
  read(1,*)n !number of frequency values
  read(2,*)   ! first line with the header
  do iw=1,n-1
     V=zero
     Vt=zero
     t=zero
     r=zero
     Jt=zero
     Jr=zero
     read(2,*) w,  V1xr,  V1yr,  V1xi,  V1yi,  V2xr,  V2yr,  V2xi, V2yi &
          ,V1dxr, V1dyr, V1dxi, V1dyi, V2dxr, V2dyr, V2dxi, V2dyi &
          ,r1r, r1i, r2r, r2i, t1r, t1i, t2r, t2i 
     !
     V(1,1)=V1xr+ci*V1xi
     V(1,2)=V2xr+ci*V2xi
     V(2,1)=V1yr+ci*V1yi
     V(2,2)=V2yr+ci*V2yi
     ! dual matrix
     Vt(1,1)=V1dxr+ci*V1dxi
     Vt(1,2)=V1dyr+ci*V1dyi
     Vt(2,1)=V2dxr+ci*V2dxi
     Vt(2,2)=V2dyr+ci*V2dyi
     ! Transmission matrix
     t(1,1)=t1r+ci*t1i
     t(2,2)=t2r+ci*t2i
     ! Reflection matrix
     r(1,1)=r1r+ci*r1i
     r(2,2)=r2r+ci*r2i
     ! Jones Matrix for the metamaterial
     Jt=matmul(V,matmul(t,Vt)) !transmission
     Jr=matmul(V,matmul(r,Vt)) !reflection
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     ! fixed Jones matrix for linear optical elements
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     if(1.eq.2) then
        Jt=zero
        Jr=zero
        !horizontal linear polarizer
        if(1.eq.2) Jt(1,1)=1.
        !vertical linear polarizer
        if(1.eq.2) Jt(2,2)=1.
     !quarter-wave plate, fast axis horizontal
        if (1.eq.2) then
           Jt(1,1)=exp(ci*pi/4.)
           Jt(2,2)=ci*exp(ci*pi/4.)
           Jr(1,1)=exp(ci*pi/4.)
           Jr(2,2)=ci*exp(ci*pi/4.)
        end if
        !quarter-wave plate, fast axis vertical
        if (1.eq.1) then
           Jt(1,1)=exp(ci*pi/4.)
           Jt(2,2)=-ci*exp(ci*pi/4.)
           Jr(1,1)=exp(ci*pi/4.)
           Jr(2,2)=-ci*exp(ci*pi/4.)
        end if
        !Homogeneous circular polarizer right
        if(1.eq.2) then
           Jt(1,1)=.5
           Jt(2,2)=.5
           Jt(1,2)=.5*ci
           Jt(2,1)=-.5*ci
        end if
        !Homogeneous circular polarizer left
        if(1.eq.2) then
           Jt(1,1)=.5
           Jt(2,2)=.5
           Jt(1,2)=-.5*ci
           Jt(2,1)=.5*ci
        end if
        !Linear polarizer 45
        if(1.eq.2) then
           Jt(1,1)=.5
           Jt(2,2)=.5
           Jt(1,2)=.5
           Jt(2,1)=.5
        end if
        !Linear polarizer -45
        if(1.eq.2) then
           Jt(1,1)=.5
           Jt(2,2)=.5
           Jt(1,2)=-.5
           Jt(2,1)=-.5
        end if
     end if
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     !elements of Mueller matrix from m_{ij}=\frac{1}{2}Tr[J\sigma_i J^\dagger \sigma_j]
     !When polarization is described looking away from the source
     !It is not clear if this prescription gives real values for m_{ij} as they must be
     !Above Jones matrices for the given linear optical elements, give the correct
     !Mueller matrices of table 8.6 of Optics by Hecht
     ! dagga Jones Matrix
     if (1.eq.1) then
        do i=1,2
           do j=1,2
              Jtd(i,j)=conjg(Jt(j,i)) 
              Jrd(i,j)=conjg(Jr(j,i)) 
           end do
        end do
        do i=0,3
           do j=0,3
              aux=matmul(Jt,matmul(sigma(i,:,:),matmul(Jtd,sigma(j,:,:))))
              !write(*,*)i,j,aux(1,1),aux(2,2) !this gives complex values
              mt(i,j)=0.5*(aux(1,1)+aux(2,2)) !since mt is defined as real, it gets the real value
              aux=matmul(Jr,matmul(sigma(i,:,:),matmul(Jrd,sigma(j,:,:))))
              mr(i,j)=0.5*(aux(1,1)+aux(2,2)) !since mt is defined as real, it gets the real value
           end do
        end do
     end if
!!!!!!!!!!!!!!!!
     !elements of Mueller matrix from C. Brosseau, Fundamentals of Polarized Light: Statistical
     !Optics Approach, Wiley, New York, 1998,
     !when polarization is described looking away from the source.
     !(dubious R. Espinosa-Luna et al, Optik 119, 757 (2008), Eq. 14b)
     !(When polarization is described looking to the source)
     !m_{ij} are real by construction
     !Above Jones matrices for the given linear optical elements, give the correct
     !Mueller matrices of table 8.6 of Optics by Hecht
     if (1.eq.2) then
        ! Transmission
        Jt1=Jt(1,1)
        Jt2=Jt(2,2)
        Jt3=Jt(2,1)
        Jt4=Jt(1,2)
        mt(0,0)=0.5*(abs(Jt(1,1))**2+abs(Jt(2,2))**2+abs(Jt(2,1))**2+abs(Jt(1,2))**2)
        mt(0,1)=0.5*(abs(Jt(1,1))**2+abs(Jt(1,2))**2-abs(Jt(2,1))**2-abs(Jt(2,2))**2)
        mt(0,2)= real(conjg(Jt(1,1))*Jt(2,1)+conjg(Jt(1,2))*Jt(2,2))
        mt(0,3)=aimag(conjg(Jt(1,1))*Jt(2,1)+conjg(Jt(1,2))*Jt(2,2))
        !
        mt(1,0)=0.5*(abs(Jt(1,1))**2-abs(Jt(1,2))**2+abs(Jt(2,1))**2-abs(Jt(2,2))**2)
        mt(1,1)=0.5*(abs(Jt(1,1))**2-abs(Jt(1,2))**2-abs(Jt(2,1))**2+abs(Jt(2,2))**2)
        mt(1,2)=real(conjg(Jt(1,1))*Jt(2,1)-conjg(Jt(1,2))*Jt(2,2))
        mt(1,3)=real(conjg(Jt(1,1))*Jt(2,1)-conjg(Jt(1,2))*Jt(2,2))
        !
        mt(2,0)=real(conjg(Jt(1,1))*Jt(1,2)+conjg(Jt(2,1))*Jt(2,2))
        mt(2,1)=real(conjg(Jt(1,1))*Jt(1,2)-conjg(Jt(2,1))*Jt(2,2))
        mt(2,2)=real(conjg(Jt(1,1))*Jt(2,2)+conjg(Jt(1,2))*Jt(1,2))
        mt(2,3)=aimag(conjg(Jt(1,1))*Jt(2,2)+conjg(Jt(1,2))*Jt(1,2))
        !
        mt(3,0)=-aimag(conjg(Jt(1,1))*Jt(1,2)+conjg(Jt(2,1))*Jt(2,2))
        mt(3,1)=-aimag(conjg(Jt(1,1))*Jt(1,2)-conjg(Jt(2,1))*Jt(2,2))
        mt(3,2)=-aimag(conjg(Jt(1,1))*Jt(2,2)-conjg(Jt(1,2))*Jt(1,2))
        mt(3,3)=real(conjg(Jt(1,1))*Jt(2,2)-conjg(Jt(1,2))*Jt(1,2))
        ! Reflection a la Luna
        Jr1=Jr(1,1)
        Jr2=Jr(2,2)
        Jr3=Jr(2,1)
        Jr4=Jr(1,2)
        mr(0,0)=0.5*(abs(Jr1)**2+abs(Jr2)**2+abs(Jr3)**2+abs(Jr4)**2)
        mr(0,1)=0.5*(abs(Jr1)**2-abs(Jr2)**2+abs(Jr3)**2-abs(Jr4)**2)
        mr(0,2)=real(Jr1*conjg(Jr4)+Jr2*conjg(Jr3))
        mr(0,3)=aimag(Jr1*conjg(Jr4)+Jr3*conjg(Jr2))
        !
        mr(1,0)=0.5*(abs(Jr1)**2-abs(Jr2)**2-abs(Jr3)**2+abs(Jr4)**2)
        mr(1,1)=0.5*(abs(Jr1)**2+abs(Jr2)**2-abs(Jr3)**2-abs(Jr4)**2)
        mr(1,2)=real(Jr1*conjg(Jr4)-Jr2*conjg(Jr3))
        mr(1,3)=aimag(Jr1*conjg(Jr4)+Jr2*conjg(Jr3))
        !
        mr(2,0)=real(Jr1*conjg(Jr3)+Jr2*conjg(Jr4))
        mr(2,1)=real(Jr1*conjg(Jr3)-Jr2*conjg(Jr4))
        mr(2,2)=real(Jr1*conjg(Jr2)+Jr3*conjg(Jr4))
        mr(2,3)=aimag(Jr1*conjg(Jr2)+Jr3*conjg(Jr4))
        !
        mr(3,0)=-aimag(Jr1*conjg(Jr3)+Jr4*conjg(Jr2))
        mr(3,1)=-aimag(Jr1*conjg(Jr3)+Jr2*conjg(Jr4))
        mr(3,2)=-aimag(Jr1*conjg(Jr2)+Jr4*conjg(Jr3))
        mr(3,3)=real(Jr1*conjg(Jr2)-Jr3*conjg(Jr4))
     end if
!!!!!!!!!!!!!!!!
     !Transmitted or Reflected Stokes Vector
     !for a given incoming Stokes vector, i.e. S_t=MS_i
     ! For unpolarized, i.e. natural light
     Si(0)=1.d0
     Si(1)=0.d0
     Si(2)=0.d0
     Si(3)=0.d0
     do i=0,3
        sumt=0.d0
        sumr=0.d0
        do j=0,3
           sumt=sumt+mt(i,j)*Si(j)
           sumr=sumr+mr(i,j)*Si(j)
        end do
        St(i)=sumt
        Sr(i)=sumr
     end do
     !Degree of polarization
     Pt=sqrt((St(1)/St(0))**2+(St(2)/St(0))**2+(St(3)/St(0))**2)!/St(0) ! Transmission
     Pr=sqrt(Sr(1)**2+Sr(2)**2+Sr(3)**2)/Sr(0) ! Reflection
     !writes data
     !Mueller matrix
     if (1.eq.2) then
        write(*,*)w
        nor=mt(0,0)
        write(*,70)mt(0,0)/nor,mt(0,1)/nor,mt(0,2)/nor,mt(0,3)/nor
        write(*,70)mt(1,0)/nor,mt(1,1)/nor,mt(1,2)/nor,mt(1,3)/nor
        write(*,70)mt(2,0)/nor,mt(2,1)/nor,mt(2,2)/nor,mt(2,3)/nor
        write(*,70)mt(3,0)/nor,mt(3,1)/nor,mt(3,2)/nor,mt(3,3)/nor
     end if
     !Mueller matrix inequalities
     if (1.eq.1) then
        do i=0,3
           do j=0,3
              if(abs(mt(i,j)).gt.mt(0,0)) then
                 write(*,*)w,i,j,'greater than 00'
              end if
           end do
        end do
     end if
     !Mueller matrix trace condition
     if (1.eq.1) then
        sumt=0
        do i=0,3
           do j=0,3
              sumt=sumt+(mt(i,j))**2
           end do
        end do
        vio=sumt-4*mt(0,0)**2
        if(vio.gt.1e-3)write(*,*)w,vio,'trace condition violated'
     end if
!!!
     write(3,69)w,St(0),St(1),St(2),St(3) &
          ,Sr(0),Sr(1),Sr(2),Sr(3)
!!! Normalized
!     write(3,69)w,Pt,St(1)/St(0),St(2)/St(0),St(3)/St(0) &
!          ,Pr,Sr(1)/Sr(0),Sr(2)/Sr(0),Sr(3)/Sr(0)
!!!
  end do !iw
69 format(f6.3,8e13.5)
70 format(4e13.4)
end program stokes
