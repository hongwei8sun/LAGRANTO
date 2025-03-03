#!/bin/bash
# NOTE : Quote it else use array to avoid problems #
 FILES="P2000*"
 for f in $FILES
 do
   echo "Finish: $f"
   # take action on each file. $f store current file name
   cdo -b F32 -f nc4c -z zip -t ecmwf copy -setgrid,era5grid  $f NEW_$f
   done

