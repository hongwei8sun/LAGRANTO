#!/bin/csh

# -------------------------------------------------
# Set some parameters
# -------------------------------------------------

# Input GRIB directory
set InputDir=/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2000

# Output netCDF directory
set OutputDir=/n/home12/hongwei/Hongwei_holyscratch01/convert/P_2000

# Start and end date for conversion, and time step
set startdate = 20000101_00
set finaldate = 20000101_21
#set finaldate = 20001231_21
set timestep  = 3

# -------------------------------------------------
# Do the conversion
# -------------------------------------------------

# Incrrement finaldate by one timestep - to include finaldate
set finaldate=`/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2000/newtime ${finaldate} ${timestep}` 

# Change to grib directory
cd ${OutputDir}

# Start loop over all dates
set date=${startdate}
loop:

cdo -b F32 -f nc4c -z zip -t ecmwf copy -setgrid,era5grid -invertlat ${InputDir}/P${date} P${date}


echo "Finish: ${date}"

# Proceed to next date
set date=`/n/home12/hongwei/HONGWEI/lagranto.ecmwf/convert/cdo_2000/newtime ${date} ${timestep}` 
if ( "${date}" != "${finaldate}" ) goto loop

exit 0
