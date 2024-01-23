#!/bin/bash


for filename in ./P*; do

  ncrename -v u,U $filename
  ncrename -v v,V $filename
  ncrename -d level,lev -v level,lev $filename
  ncrename -d longitude,lon -v longitude,lon $filename
  ncrename -d latitude,lat -v latitude,lat $filename

done

