#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#inputs
bus_device=$1
regions_number=$2

for (( i = 0; i < $regions_number; i++ ))
do 
    echo $i
    sudo $CLI_PATH/program/fpga_chmod $bus_device $i
done