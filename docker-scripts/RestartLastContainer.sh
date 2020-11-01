#!/bin/bash

lastContainer=`docker ps -a --format 'CONTAINER ID : {{.ID}}' | awk 'NR==1{print $4}'`

if [[ ! $lastContainer ]]; then
        echo "container does not exist"
else
        echo "Starting container... "
        docker start $lastContainer
        echo "+++++++++++++++++++++"
        docker ps
        echo "+++++++++++++++++++++"
        echo "Container successfully started!"
fi