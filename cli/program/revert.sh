#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/program/revert --device $device_index --version $vivado_version
#example: /opt/sgrt/cli/program/revert --device             1

#inputs
device_index=$2
vivado_version=$4

#constants
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)
SERVERADDR="localhost"
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)

#derived
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#check on workflow
workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
if [[ $workflow = "vitis" ]]; then
    exit
fi

#get upstream_port
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

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
    #echo ""
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
#echo ""

#author: https://github.com/jmoya82