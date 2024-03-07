#!/bin/sh

bus_device=$1
index=$2

#echo $bus_device
#echo $index
#echo "/dev/fpga_${bus_device}_v$index"

if sudo true; then
    #enable pr region
    #if [[ $index -eq 0 ]]; then
    if [ $index -eq 0 ]; then
        echo "chmod 666 /dev/fpga_${bus_device}_pr"
        chmod 666 /dev/fpga_${bus_device}_pr
    fi
    #enable vFPGA
    echo "chmod 666 /dev/fpga_${bus_device}_v$index"
    chmod 666 /dev/fpga_${bus_device}_v$index
else
    echo ""
    echo "$0: sorry, you are not allowed to run this script."
    echo ""
    exit 1
fi