#!/bin/bash

#
#for filename in /n/holystore01/LABS/keith_lab_seas/Lab/hongwei/lagranto.ecmwf/ERA5_model/2000/daily/UVW/*.grb; do
#    ln -sf $filename /n/holystore01/LABS/keith_lab_seas/Lab/hongwei/lagranto.ecmwf/ERA5_model/2000/3-hour/UVW/
#done
#
##
#for filename in ./*.grb; do
#    mv $filename "${filename/.grb/_}"
#done
#
#
#sleep 15

#
for filename in ./an*; do
    cdo splithour $filename $filename
done

#
for filename in ./*.grb; do
    mv $filename "${filename/.grb/_tuvw}"
done

#
#for filename in /n/holystore01/LABS/keith_lab_seas/Lab/hongwei/lagranto.ecmwf/ERA5_model/2000/monthly/lnsp/*.grb; do
#    cdo splitday $filename $filename
#done
