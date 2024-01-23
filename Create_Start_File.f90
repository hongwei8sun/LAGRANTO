Program Create_Start_File

IMPLICIT NONE

  integer :: ix, iy, iz

  real	:: lon(36), lat(21), P(5)


  P = (/100, 75, 55, 40, 30/)

  DO ix = 1, 36, 1
    lon(ix) = (ix-1)*10.0
  ENDDO

  DO iy = 1,21,1
    lat(iy) = -20 + (iy-1)*2
  ENDDO



  OPEN(502, FILE="startf.all", STATUS='REPLACE',  &
       FORM='FORMATTED',    ACCESS='SEQUENTIAL' )

  DO ix = 1, 36, 1
  DO iy = 1, 21, 1
  DO iz = 1,5,1

    WRITE(502,'(3f10.3)') lon(ix), lat(iy), P(iz)

  ENDDO
  ENDDO
  ENDDO

  CLOSE(502)

END Program
