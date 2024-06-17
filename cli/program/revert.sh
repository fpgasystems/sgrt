#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)
SERVERADDR="localhost"

#get username
username=$USER

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on virtualized
virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)
if [ "$virtualized" = "1" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit
fi

#check on ACAP or FPGA servers (server must have at least one ACAP or one FPGA)
acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit
fi

#get Vivado version
#vivado_version=$(find "$VIVADO_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

#check on valid Vivado version (using $XILINX_VIVADO is not possible)
#if [ ! -d $VIVADO_PATH/$vivado_version ]; then
#    echo ""
#    echo "Please, source a valid Vivado version for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check on valid Vivado version
#vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)

#if [ -z "$vivado_version" ]; then #if [ -z "$(echo $vivado_version)" ]; then
#    echo ""
#    echo "Please, source a valid Vivado version for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#inputs
read -a flags <<< "$@"

#version_dialog_check
result="$("$CLI_PATH/common/version_dialog_check" "${flags[@]}")"
vivado_version=$(echo "$result" | sed -n '2p')

#check on Vivado version
if [ -n "$vivado_version" ]; then
    #vivado_version is not empty and we check if the Vivado directory exists
    if [ ! -d $VIVADO_PATH/$vivado_version ]; then
        echo ""
        echo "Please, choose a valid Vivado version for ${bold}$hostname!${normal}"
        echo ""
        exit 1
    fi
else
    #vivado_version is empty and we set the more recent Vivado version by default
    vivado_version=$(find "$VIVADO_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -V | tail -n 1)

    #vivado_version and VIVADO_PATH are empty
    if [ -z "$vivado_version" ]; then
        echo ""
        echo "Please, source a valid Vivado version for ${bold}$hostname!${normal}"
        echo ""
        exit 1
    fi
fi

#check on flags
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    #device_dialog
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    else
        echo ""
        echo "${bold}Please, choose your device:${normal}"
        echo ""
        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
        device_found=$(echo "$result" | sed -n '1p')
        device_index=$(echo "$result" | sed -n '2p')
    fi
else
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        $CLI_PATH/help/program_revert
        exit
    fi
    #device_dialog (forgotten mandatory)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        $CLI_PATH/help/program_revert
        exit
    fi
fi

#get BDF (i.e., Bus:Device.Function) 
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
bdf="${upstream_port%??}" #i.e., we transform 81:00.0 into 81:00

#check on number of pci functions
if [[ $(lspci | grep Xilinx | grep $bdf | wc -l) = 2 ]]; then
    #echo ""
    #lspci | grep Xilinx | grep $bdf
    #echo ""
    #print additional echo
    if [ "$flags" = "" ]; then
        echo ""
    fi
    exit
fi

echo ""
echo "${bold}sgutil program revert${normal}"

#get loaded drivers
if [ -d "$MY_DRIVERS_PATH" ]; then
    # Initialize vectors
    drivers=()
    loaded_drivers=()

    # Iterate over each file in the directory
    for file in "$MY_DRIVERS_PATH"/*; do
        # Extract file name without path
        filename=$(basename "$file")
        # Add file name to the array
        drivers+=("$filename")
    done

    # Filter drivers array
    for driver in "${drivers[@]}"; do
        if lsmod | grep -q "${driver%.*}"; then
            # Driver is currently loaded, add it to the loaded_drivers array
            loaded_drivers+=("$driver")
        fi
    done
fi

#remove loaded drivers
if [ "${#loaded_drivers[@]}" -gt 0 ]; then
    echo ""
    echo "${bold}Removing drivers:${normal}"
    echo ""

    for driver in "${loaded_drivers[@]}"; do
        echo "sudo rmmod ${driver%.*}"
        sudo rmmod "${driver%.*}" 2>/dev/null # with 2>/dev/null we avoid printing a message if the module does not exist
    done
fi

#get device and serial name
serial_number=$($CLI_PATH/get/serial -d $device_index | awk -F': ' '{print $2}' | grep -v '^$')
device_name=$($CLI_PATH/get/name -d $device_index | awk -F': ' '{print $2}' | grep -v '^$')

echo ""
echo "${bold}Programming XRT shell:${normal}"

$VIVADO_PATH/$vivado_version/bin/vivado -nolog -nojournal -mode batch -source $CLI_PATH/program/flash_xrt_bitstream.tcl -tclargs $SERVERADDR $serial_number $device_name

#hotplug
root_port=$($CLI_PATH/get/get_fpga_device_param $device_index root_port)
LinkCtl=$($CLI_PATH/get/get_fpga_device_param $device_index LinkCtl)
sudo $CLI_PATH/program/pci_hot_plug 1 $upstream_port $root_port $LinkCtl

#inserting XRT driver
echo "${bold}Inserting XRT drivers:${normal}"
echo ""

if [[ $(lsmod | grep xocl | wc -l) -gt 0 ]]; then
    echo "sudo modprobe xocl"
    sudo modprobe xocl
    sleep 1
fi
if [[ $(lsmod | grep xclmgmt | wc -l) -gt 0 ]]; then
    echo "sudo modprobe xclmgmt"
    sudo modprobe xclmgmt
    sleep 1
fi
echo ""
#lspci | grep Xilinx | grep $bdf
#echo ""