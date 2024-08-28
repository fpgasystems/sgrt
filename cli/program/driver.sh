#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/program/driver --insert $driver_name --params $params_string
#example: /opt/sgrt/cli/program/driver --insert      onic.ko --params RS_FEC_ENABLED=0

#inputs
driver_name=$2
params_string=$4

#constants
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)

#create folder
if [ ! -d "$MY_DRIVERS_PATH" ]; then
    mkdir "$MY_DRIVERS_PATH"
fi

#get actual filename (i.e. onik.ko without the path)
driver_name_base=$(basename "$driver_name")

#inserting driver
insert_driver="0"
if ! lsmod | grep -q ${driver_name_base%.ko}; then
    insert_driver="1"
else
    echo "The driver ${bold}${driver_name_base%.ko}${normal} is already inserted. Do you want to remove it and insert it again (y/n)?"
    while true; do
        read -p "" yn
        case $yn in
            "y")
                insert_driver="1"
                echo ""
                echo "${bold}Removing driver:${normal}"
                echo ""
                echo "sudo rmmod ${driver_name_base%.ko}"
                sudo rmmod ${driver_name_base%.ko}
                break
                ;;
            "n") 
                #compile="0"
                break
                ;;
        esac
    done
    echo ""
fi

#inserting the driver
if [ "$insert_driver" = "1" ]; then 
    #change ownership to ensure writing permissions
    sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH

    #we need to copy the driver to /local to avoid permission problems
    echo "${bold}Copying driver to $MY_DRIVERS_PATH:${normal}"
    echo ""
    echo "cp -f $driver_name $MY_DRIVERS_PATH"
    echo ""
    
    #copy driver
    cp -f $driver_name $MY_DRIVERS_PATH

    #echo ""
    echo "${bold}Inserting $driver_name_base driver:${normal}"
    echo ""

    #replace commas with spaces
    params_string=$(echo "$params_string" | tr ',' ' ')
    params_string=$(echo "$params_string" | tr ';' ' ')

    echo "sudo insmod $MY_DRIVERS_PATH/$driver_name_base $params_string"
    sudo insmod $MY_DRIVERS_PATH/$driver_name_base $params_string
    sleep 1
    echo ""
fi

#author: https://github.com/jmoya82