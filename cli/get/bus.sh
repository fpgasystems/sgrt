#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
IS_GPU_DEVELOPER="1"
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
gpu_enabled=$($CLI_PATH/common/is_enabled "gpu" $is_acap $is_fpga $is_gpu $IS_GPU_DEVELOPER $is_vivado_developer)
if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "0" ]; then
    exit
fi

#constants
DEVICES_LIST="$CLI_PATH/devices_gpu"

# Check if the file is empty
if [ ! -s "$DEVICES_LIST" ]; then
    exit 1
fi

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of gpu devices present
MAX_DEVICES=$(grep -E "gpu" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#inputs
read -a flags <<< "$@"

#check on flags
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    echo ""
    #print devices information
    for device_index in $(seq 1 $MAX_DEVICES); do 
        bus=$($CLI_PATH/get/get_gpu_device_param $device_index bus)
        if [ -n "$bus" ]; then
            echo "$device_index: $bus"
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
        $CLI_PATH/sgutil get bus -h
        exit
    fi
    #device_dialog (forgotten mandatory)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        $CLI_PATH/sgutil get bus -h
        exit
    fi
    #print
    bus=$($CLI_PATH/get/get_gpu_device_param $device_index bus)
    echo ""
    echo "$device_index: $bus"
    echo ""
fi