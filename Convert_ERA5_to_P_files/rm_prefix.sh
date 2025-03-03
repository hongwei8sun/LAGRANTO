#!/bin/bash
# NOTE : Quote it else use array to avoid problems #

 for file in NEW_* ; do
   echo $file
   mv -v "$file" "${file#*_}"
 done


