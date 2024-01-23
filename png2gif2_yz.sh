#!/bin/bash

rm -rf *.gif

convert  -delay  100  0_yz.png   -loop  0  0_YZ2.gif

for ((i=1; i<=151; i++))

do
echo $i
convert  -delay 100  ${i}_yz.png   -loop  0  ${i}_YZ2.gif
convert  -delay 100 $[i-1]_YZ2.gif  ${i}_YZ2.gif  ${i}_YZ2.gif
rm -rf $[i-1]_YZ2.gif

done

