#!/bin/csh

# -------------------------------------------------
# Set some parameters
# -------------------------------------------------

# Input GRIB directory
set grbdir=/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2000

# Output netCDF directory
set cdfdir=/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2000

# Start and end date for conversion, and time step
set startdate = 20000101_00
set finaldate = 20001231_21
set timestep  = 3

# -------------------------------------------------
# Do the conversion
# -------------------------------------------------

# Incrrement finaldate by one timestep - to include finaldate
set finaldate=`/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2000/newtime ${finaldate} ${timestep}` 

# Change to grib directory
cd ${cdfdir}

# Start loop over all dates
set date=${startdate}
loop:

# Convert an${date}_uvwt
\rm -f P${date}_tuvw
\rm -f S${date}_tuvw
cdo -b F32 -f nc4c -z zip -t ecmwf copy -setgrid,era5grid -setzaxis,L137_levels -invertlat -chname,w,OMEGA -chname,u,U -chname,v,V ${grbdir}/an${date}_tuvw P${date}_tuvw


# Convert an${date}_T
 \rm -f P${date}_T
 cdo  -b F32 -f nc4c -z zip  -t ecmwf copy -setgrid,era5grid  -setzaxis,L137_levels -invertlat -chname,t,T ${grbdir}/an${date}_T P${date}_T


# Convert an${date}_ps
 \rm -f P${date}_ps
 cdo -b F32 -f nc4c -z zip -t ecmwf copy -setgrid,era5grid  -setzaxis,L137_surface -invertlat ${grbdir}/an${date}_ps P${date}_ps_scratch
# cdo -f nc -t ecmwf copy -setzaxis,L137_surface -invertlat ${grbdir}/an${date}_ps P${date}_ps_scratch
# For model level:
# cdo -O -f nc -b 64 -L expr,'PS=0.01*exp(lnsp)' P${date}_ps_scratch P${date}_ps
 ncap2 -s 'PS=0.01*exp(lnsp)' P${date}_ps_scratch P${date}_ps1
 cdo -setattribute,PS@units="hPa" P${date}_ps1 P${date}_ps
# For pressure level:
# cdo -O -f nc -b 64 -L expr,'PS=0.01*sp' P${date}_ps_scratch P${date}_ps


#
# # Merge all files
 \rm -f P${date}
 cdo -f nc merge P${date}_tuvw P${date}_T P${date}_ps P${date}_all

# calculate THETA:
 cdo pressure_fl P${date}_all P${date}_fl
 cdo -f nc merge P${date}_all P${date}_fl P${date}_TH	# combine full level pressure with temperature data
 ncap2 -O -s 'TH=T*(100000/pressure)^0.285' P${date}_TH P${date}_TH	# use pressure and temperature to get theta


# create P files and S files
 mv P${date}_all P${date}
# cdo -L -f nc merge P${date}_TH P${date}_ps S${date}

 \rm -f P${date}_tuvw
 \rm -f P${date}_T
 \rm -f P${date}_TH
 \rm -f P${date}_ps
 \rm -f P${date}_ps1
 \rm -f P${date}_ps_scratch
 \rm -f P${date}_all
 \rm -f P${date}_fl

echo "Finish: ${date}"

# Proceed to next date
set date=`/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2000/newtime ${date} ${timestep}` 
if ( "${date}" != "${finaldate}" ) goto loop

exit 0
