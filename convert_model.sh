#!/bin/csh

# -------------------------------------------------
# Set some parameters
# -------------------------------------------------
rm -rf an2004*

ln -sf /n/home12/hongwei/HONGWEI/lagranto.ecmwf/ERA5_model/2004/3-hour/UVW/an2004* .
ln -sf /n/home12/hongwei/HONGWEI/lagranto.ecmwf/ERA5_model/2004/3-hour/T/an2004* .
ln -sf /n/home12/hongwei/HONGWEI/lagranto.ecmwf/ERA5_model/2004/3-hour/lnsp/an2004* .

# Input GRIB directory
set grbdir=/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2004

# Output netCDF directory
set cdfdir=/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2004

# Start and end date for conversion, and time step
set startdate = 20040101_00
set finaldate = 20041231_21
set timestep  = 3

# -------------------------------------------------
# Do the conversion
# -------------------------------------------------

# Incrrement finaldate by one timestep - to include finaldate
set finaldate=`/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2004/newtime ${finaldate} ${timestep}` 

# Change to grib directory
cd ${cdfdir}

# Start loop over all dates
set date=${startdate}
loop:

# Convert an${date}_uvwt
\rm -f P${date}_tuvw
cdo -f nc -t ecmwf copy -invertlat -chname,w,OMEGA -chname,u,U -chname,v,V ${grbdir}/an${date}_tuvw P${date}_tuvw

echo "pass tuvw"

# Convert an${date}_T
 \rm -f P${date}_T
 cdo -f nc -t ecmwf copy -invertlat -chname,t,T ${grbdir}/an${date}_T P${date}_T

echo "pass T"

# Convert an${date}_ps
 \rm -f P${date}_ps
 cdo -f nc -t ecmwf copy -invertlat ${grbdir}/an${date}_ps P${date}_ps_scratch
# For model level:
 cdo -O -f nc -b 64 -L expr,'PS=0.01*exp(lnsp)' P${date}_ps_scratch P${date}_ps
# For pressure level:
# cdo -O -f nc -b 64 -L expr,'PS=0.01*sp' P${date}_ps_scratch P${date}_ps

echo "pass ps"

#
# # Merge all files
 \rm -f P${date}
 cdo -f nc merge P${date}_tuvw P${date}_T P${date}_ps P${date}
# cdo -f nc merge P${date}_tuvw P${date}_ps P${date}
 \rm -f P${date}_tuvw
 \rm -f P${date}_T
 \rm -f P${date}_ps
 \rm -f P${date}_ps_scratch

# Proceed to next date
set date=`/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2004/newtime ${date} ${timestep}` 
if ( "${date}" != "${finaldate}" ) goto loop

exit 0
