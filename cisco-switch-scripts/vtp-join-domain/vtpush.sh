#!/bin/bash

# Open device list & send the collected information to script
for device in `cat switch`; 
do
    ./vtpDomain.sh $device; #joins devices into vtp domain
    #./vtpTransparent.sh $device;  #removes vtp domain
done
