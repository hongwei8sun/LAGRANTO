#!/bin/csh


# Write usage information
if ( ${#argv} == 0) then
  echo 
  ${LAGRANTO}/bin/lagrantohelp traj2num short
  echo  
  exit 0
endif

set inpfile = $1
set outfile = $2
set mode    = $3
if ( "${mode}" == "proxy" ) then
   set clon   = $4
   set clat   = $5
   set radius = $6
endif

set dim=`${LAGRANTO}/goodies/trainfo.sh ${inpfile} dim` 

\rm -f traj2num.param
echo \"${inpfile}\"  >! traj2num.param
echo \"${outfile}\"  >> traj2num.param
echo ${dim}          >> traj2num.param
echo \"${mode}\"     >> traj2num.param

if ( "${mode}" == "proxy" ) then
  echo ${clon}      >> traj2num.param
  echo ${clat}      >> traj2num.param
  echo ${radius}    >> traj2num.param
endif

${LAGRANTO}/tools/traj2num

#\rm -f traj2num.param

exit 0

