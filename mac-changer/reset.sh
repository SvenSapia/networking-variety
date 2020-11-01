#!/bin/bash

# identify default network interface 
defaultInterface=`route | grep '^default' | grep -o '[^ ]*$'`

# identify current MAC address
currentMAC=`ip link show $defaultInterface | awk '/ether/ {print $2}'`

# capture vendor MAC address
vendorMAC=`ethtool -P $defaultInterface | awk '{print $3}'`

# reset mac address if not equal to hardware specific vendor mac address
if [[ $currentMAC == $vendorMAC ]];
then
    echo "MAC address has not been modified, no change will take place."
    exit 0
else    
    # shut interface
    shutInt=`sudo ip link set dev $defaultInterface down`
    # apply new MAC address
    resetMAC=`sudo ip link set dev $defaultInterface address $vendorMAC`
    # start interface
    upInt=`sudo ip link set dev $defaultInterface up`
    
    latestMAC=`sudo ip link show $defaultInterface | awk '/ether/ {print $2}'`
    
    echo "MAC addresses resetted to: $latestMAC" 
fi
