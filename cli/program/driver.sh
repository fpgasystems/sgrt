#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)

#check on vivado_developers
member=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$member" = "false" ]; then
    echo ""
    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
    echo ""
    exit
fi

#inputs
read -a flags <<< "$@"

#check on flags
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    $CLI_PATH/sgutil program driver -h
    exit
else
    #driver_dialog_check
    result="$("$CLI_PATH/common/driver_dialog_check" "${flags[@]}")"
    driver_found=$(echo "$result" | sed -n '1p')
    driver_name=$(echo "$result" | sed -n '2p') 

    #forbidden combinations (1)
    if [ "$driver_found" = "0" ]; then
        $CLI_PATH/sgutil program driver -h
        exit
    fi
    #forbidden combinations (2)
    if [ "$driver_found" = "1" ] && ([ "$driver_name" = "" ] || [ ! -f "$driver_name" ] || [ "${driver_name##*.}" != "ko" ]); then
        $CLI_PATH/sgutil program driver -h
        exit
    fi
    #params_dialog_check
    result="$("$CLI_PATH/common/params_dialog_check" "${flags[@]}")"
    params_found=$(echo "$result" | sed -n '1p')
    params_string=$(echo "$result" | sed -n '2p')

    #define the expected pattern for driver parameters
    pattern='^[^=,]+=[^=,]+(,[^=,]+=[^=,]+)*$' 

    #forbidden combinations (3)
    if [ "$params_found" = "1" ] && ([ "$params_string" = "" ] || ! [[ $params_string =~ $pattern ]]); then
        $CLI_PATH/sgutil program driver -h
        exit
    fi

fi

echo ""
echo "${bold}sgutil program driver${normal}"

#create folder
if [ ! -d "$MY_DRIVERS_PATH" ]; then
    mkdir "$MY_DRIVERS_PATH"
fi

#change ownership to ensure writing permissions
sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH

#we need to copy the driver to /local to avoid permission problems
echo ""
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