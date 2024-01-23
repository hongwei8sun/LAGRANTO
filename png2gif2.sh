#!/bin/bash

rm -rf *.gif

convert  -delay  100  0_xy.png   -loop  0  0_2.gif

for ((i=1; i<=151; i++))

do
echo $i
convert  -delay 100  ${i}_xy.png   -loop  0  ${i}_2.gif
convert  -delay 100 $[i-1]_2.gif  ${i}_2.gif  ${i}_2.gif
rm -rf $[i-1]_2.gif

done

