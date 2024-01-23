PROGRAM test

  IMPLICIT NONE



  real :: D_lon, D_lat
  INTEGER :: ix, iy, iz

  REAL :: Press


  D_lon = 15
  D_lat = 3
   
  Press = 47


  OPEN(265, FILE='startf_21km.final', status='replace', access="SEQUENTIAL")

  DO ix = 1,24,1
  DO iy = 1,21,1

    WRITE(265,"(f10.3, f10.3, f10.3)") (ix-1)*D_lon, -30.0+(iy-1)*D_lat, Press

  ENDDO
  ENDDO

END PROGRAM test
