#!/bin/csh

# -------------------------------------------------
# Set some parameters
# -------------------------------------------------

# Input GRIB directory
set grbdir=/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo

# Output netCDF directory
set cdfdir=/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo

# Start and end date for conversion, and time step
set startdate = 20090129_00
set finaldate = 20090131_18
set timestep  = 6

# -------------------------------------------------
# Do the conversion
# -------------------------------------------------

# Incrrement finaldate by one timestep - to include finaldate
set finaldate=`/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo/newtime ${finaldate} ${timestep}` 

# Change to grib directory
cd ${cdfdir}

# Start loop over all dates
set date=${startdate}
loop:

# Convert an${date}_uvwt
\rm -f P${date}_tuvw
cdo -f nc -t ecmwf copy -invertlat -chname,W,OMEGA ${grbdir}/an${date}_tuvw P${date}_tuvw

echo "pass tuvw"

# Convert an${date}_q
 \rm -f P${date}_q
 cdo -f nc -t ecmwf copy -invertlat ${grbdir}/an${date}_q P${date}_q

echo "pass q"

# Convert an${date}_ps
 \rm -f P${date}_ps
 cdo -f nc -t ecmwf copy -invertlat ${grbdir}/an${date}_ps P${date}_ps_scratch
# For model level:
 cdo -O -f nc -b 64 -L expr,'PS=0.01*exp(LNSP)' P${date}_ps_scratch P${date}_ps
# For pressure level:
# cdo -O -f nc -b 64 -L expr,'PS=0.01*SP' P${date}_ps_scratch P${date}_ps

echo "pass ps"

#
# # Merge all files
 \rm -f P${date}
 cdo -f nc merge P${date}_tuvw P${date}_q P${date}_ps P${date}
# cdo -f nc merge P${date}_tuvw P${date}_ps P${date}
 \rm -f P${date}_tuvw
 \rm -f P${date}_q
 \rm -f P${date}_ps
 \rm -f P${date}_ps_scratch

# Proceed to next date
set date=`/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo/newtime ${date} ${timestep}` 
if ( "${date}" != "${finaldate}" ) goto loop

exit 0
