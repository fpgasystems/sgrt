#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
PLATFORMINFO_LIST="$CLI_PATH/platforminfo"
PLATFORMINFO_PARAMETER="Clock Information:"

get_platforminfo_parameter() {
    #read input parameters
    PLATFORMINFO_PARAMETER=$1
    platform=$2
    PLATFORMINFO_LIST=$3

    #find the line number where the target string is found
    line_number=$(grep -n "$platform" $PLATFORMINFO_LIST | cut -d: -f1)
    #extract the content starting from the line where the target string is found and pipe it to another grep to find the line with the $PLATFORMINFO_PARAMETER
    result=$(sed -n "${line_number},\$p" $PLATFORMINFO_LIST | grep -m 1 "$PLATFORMINFO_PARAMETER" | grep -oP '(?<=: ).*') # cut -d: -f2-
    
    #return value
    echo $result
}

get_slr_num() {
    #read input parameters
    platform=$1
    PLATFORMINFO_LIST=$2

    #get number of SLRs
    i=0
    while true; do
        slr=$(get_platforminfo_parameter "SLR$i" "$platform" "$PLATFORMINFO_LIST")
        if [ -z "$slr" ]; then
            break
        fi
        # do something with slr
        ((i++)) # increment i for the next iteration
    done

    #return value
    echo $i
}

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on build server
cpu=$($CLI_PATH/common/is_cpu $CLI_PATH $hostname)
if [ "$cpu" = "1" ]; then
    echo ""
    ls -l $XILINX_PLATFORMS_PATH/ | grep '^d' | awk '{print $NF}'
    echo ""
    exit
fi

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap" $DEVICES_LIST | wc -l)

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
        #get platform
        platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
        
        #get number of SLRs
        SLR_num=$(get_slr_num "$platform" "$PLATFORMINFO_LIST")
        
        #print 
        echo "$device_index:"

        if [ -n "$platform" ]; then
            #slrs=()
            for ((i=0; i<SLR_num; i++)); do
                slr=$(get_platforminfo_parameter "SLR$i" "$platform" "$PLATFORMINFO_LIST")
                #slrs+=("$slr")
                #print
                echo "SLR$i: $slr"
            done
        fi
        
        #print        
        #if [ -n "$platform" ]; then
        #    echo "$device_index:"
        #    for slr in "${slrs[@]}"; do
        #        echo "$slr"  # Echo each element of the array
        #    done
        #fi
    done
    echo ""
else
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        $CLI_PATH/sgutil get clock -h
        exit
    fi
    #device_dialog (forgotten mandatory)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        $CLI_PATH/sgutil get clock -h
        exit
    fi
    
    #get platform
    platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)

    #get parameter
    clock=$(get_platforminfo_parameter "$PLATFORMINFO_PARAMETER" "$platform" "$PLATFORMINFO_LIST")

    #print
    echo ""
    echo "$device_index: $clock"
    echo ""
fi