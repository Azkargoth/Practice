  program minimum
  implicit none
  real, allocatable :: w(:),f(:),t(:)
  integer i,n
  integer v_maxloc(1)
  real v_maxval
  integer v_minloc(1)
  real v_minval
  real x
!!!
  ! reads number of data
  read(*,*)n
   allocate(f(n-1))
   allocate(t(n-1))
   allocate(w(n-1))
  ! reads header
  !1 2 3  4  5      6           7         8 9  10 11     12          13 
  !w R ar br angler flatteningr helicityr T at bt anglet flatteningt helicityt
  read(1,*)
  ! reads data
  do i=1,n-1
             !1    2 3 4 5 6 7 8    9 10  11 12   13
     read(1,*)w(i),x,x,x,x,x,x,t(i),x,x , x ,f(i),x
  end do
  
  v_maxval =  maxval ( f )
  v_maxloc =  maxloc ( f )
  v_minval =  minval ( f )
  v_minloc =  minloc ( f )
  write(*,*)w(v_minloc(1)),t(v_minloc(1))
  
!!$  write ( *, '(a)' ) ' '
!!$  write ( *, '(a,g14.6)' ) '  v_maxval = ', v_maxval
!!$  write ( *, '(a,i6)' )    '  v_maxloc = ', v_maxloc(1)
!!$  write ( *, '(a,g14.6)' ) '  v_minval = ', v_minval
!!$  write ( *, '(a,i6)' )    '  v_minloc = ', v_minloc(1)

end program minimum


