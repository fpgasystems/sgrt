#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
DEVICES_LIST="$CLI_PATH/devices_network"

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "nic" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#inputs
read -a flags <<< "$@"

#helper functions
split_addresses (){
  #input parameters
  str_ip=$1
  str_mac=$2
  aux=$3
  #save the current IFS
  OLDIFS=$IFS
  #set the IFS to / to split the string at each /
  IFS="/"
  #read the two parts of the string into variables
  read ip0 ip1 <<< "$str_ip"
  read mac0 mac1 <<< "$str_mac"
  #reset the IFS to its original value
  IFS=$OLDIFS
  #print the two parts of the string
  if [[ "$aux" == "0" ]]; then
    echo "$ip0 ($mac0)"
  else
    echo "$ip1 ($mac1)"
  fi
}

#check on flags
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    echo ""
    #print devices information
    for device_index in $(seq 1 $MAX_DEVICES); do 
        ip=$($CLI_PATH/get/get_nic_device_param $device_index IP)
        if [ -n "$ip" ]; then
            mac=$($CLI_PATH/get/get_nic_device_param $device_index MAC)
            add_0=$(split_addresses $ip $mac 0)
            add_1=$(split_addresses $ip $mac 1)
            name="$device_index" 
            name_length=$(( ${#name} + 1 ))
            echo "$name: $add_0"
            printf "%-${name_length}s %s\n" "" "$add_1"
        fi
    done
    echo ""
else
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        $CLI_PATH/sgutil get ifconfig -h
        exit
    fi
    #port_dialog_check
    result="$("$CLI_PATH/common/port_dialog_check" "${flags[@]}")"
    port_found=$(echo "$result" | sed -n '1p')
    port_index=$(echo "$result" | sed -n '2p')
    #device_dialog (forgotten mandatory)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        $CLI_PATH/sgutil get ifconfig -h
        exit
    fi
    #forbidden combinations (port)
    MAX_NUM_PORTS=$($CLI_PATH/get/get_nic_device_param $device_index IP | grep -o '/' | wc -l)
    MAX_NUM_PORTS=$((MAX_NUM_PORTS + 1))
    if ([ "$port_found" = "1" ] && [ "$port_index" = "" ]) || ([ "$port_found" = "1" ] && ([[ "$port_index" -gt "$MAX_NUM_PORTS" ]] || [[ "$port_index" -lt 1 ]])); then
        echo "HEY!" 
        $CLI_PATH/sgutil get ifconfig -h
        exit
    fi
    
    #get values
    ip=$($CLI_PATH/get/get_nic_device_param $device_index IP)
    mac=$($CLI_PATH/get/get_nic_device_param $device_index MAC)
    add_0=$(split_addresses $ip $mac 0)
    add_1=$(split_addresses $ip $mac 1)
    name="$device_index"
    name_length=$(( ${#name} + 1 ))

    #print
    if [[ $port_found = "0" ]]; then
        echo ""
        echo "$name: $add_0"
        printf "%-${name_length}s %s\n" "" "$add_1"
        echo ""
    else
        port_index=$((port_index - 1))
        var_name="add_$port_index" # Create the variable name string
        echo ""
        echo "$name: ${!var_name}" 
        echo ""
    fi
fi


##get mellanox name
#mellanox_name=$(nmcli dev | grep mellanox-0 | awk '{print $1}')
#ip_mellanox=$(ip addr show $mellanox_name | awk '/inet / {print $2}' | awk -F/ '{print $1}')
#mac_mellanox=$(ip addr show $mellanox_name | grep -oE 'link/ether [^ ]+' | awk '{print toupper($2)}')

#echo ""
#echo "0: $ip_mellanox ($mac_mellanox)"
#echo ""