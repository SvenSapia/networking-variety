#!/bin/bash

# identify default network interface 
defaultInterface=`route | grep '^default' | grep -o '[^ ]*$'`

# get current mac address
currentMac=`ip link show $defaultInterface | awk '/ether/ {print $2}'`

echo "Current MAC address in use: |$currentMac|" \

if [[ ! -z $currentMac ]];
then
    # generate a random mac address
    randomMac=`sudo openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'`
    echo "Random MAC address: |$randomMac|" \ 
    
    if [[ $currentMac == $randomMac ]];
    then
        # if newly generated mac address is identical to the current mac address exit application
        echo "MAC address identical to new address, closing application..."
        sleep 2
        exit 0
    else
        # temporarily disable interface to avoid error message
        shutInt=`sudo ip link set dev $defaultInterface down`
        # apply newly generated mac address
        applyGeneratedMac=`sudo ip link set dev $defaultInterface address $randomMac`
        # enable interface
        upInt=`sudo ip link set dev $defaultInterface up`
        # print new interface mac address
        newInterfaceMac=`ip link show $defaultInterface | awk '/ether/ {print $2}'`
        # verify whether mac has changed
        echo "Applying random MAC address |$newInterfaceMac| to interface ($defaultInterface)"
    fi
fi

