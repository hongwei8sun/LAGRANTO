#!/bin/bash

#
for filename in /n/holystore01/LABS/keith_lab_seas/Lab/hongwei/lagranto.ecmwf/ERA5_model/2000/monthly/lnsp/*.grb; do
    ln -sf $filename /n/holystore01/LABS/keith_lab_seas/Lab/hongwei/lagranto.ecmwf/ERA5_model/2000/daily/lnsp/
done

#
for filename in ./*.grb; do
    mv $filename "${filename/.grb/}"
done
#
#
for filename in ./an*; do
    cdo splitday $filename $filename
done
#
#for filename in /n/holystore01/LABS/keith_lab_seas/Lab/hongwei/lagranto.ecmwf/ERA5_model/2000/monthly/lnsp/*.grb; do
#    cdo splitday $filename $filename
#done
