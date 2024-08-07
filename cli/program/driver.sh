#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/program/driver --module $driver_name --params $params_string
#example: /opt/sgrt/cli/program/driver --module      onic.ko --params RS_FEC_ENABLED=0

#inputs
driver_name=$2
params_string=$4

#constants
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)

#create folder
if [ ! -d "$MY_DRIVERS_PATH" ]; then
    mkdir "$MY_DRIVERS_PATH"
fi

#change ownership to ensure writing permissions
sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH

#we need to copy the driver to /local to avoid permission problems
#echo ""
echo "${bold}Copying driver to $MY_DRIVERS_PATH:${normal}"
echo ""
echo "cp -f $driver_name $MY_DRIVERS_PATH"

#remove first
sudo $CLI_PATH/common/rm $MY_DRIVERS_PATH/$driver_name

#copy driver
cp -f $driver_name $MY_DRIVERS_PATH

#insert coyote driver
echo ""
echo "${bold}Inserting driver:${normal}"
echo ""

#get actual filename
driver_name=$(basename "$driver_name")

#replace commas with spaces
params_string=$(echo "$params_string" | tr ',' ' ')
params_string=$(echo "$params_string" | tr ';' ' ')

#we always remove and insert the driver
echo "sudo rmmod ${driver_name%.ko}"
sudo rmmod ${driver_name%.ko} 2>/dev/null # with 2>/dev/null we avoid printing a message if the module does not exist
sleep 1
echo "sudo insmod $MY_DRIVERS_PATH/$driver_name $params_string"
sudo insmod $MY_DRIVERS_PATH/$driver_name $params_string
sleep 1
echo ""

#author: https://github.com/jmoya82