#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil program vivado --bitstream         $bitstream_name --device $device_index --version $vivado_version
#example: /opt/sgrt/cli/sgutil program vivado --bitstream    path_to_my_shell.bit --device             1 --version          2022.1

#inputs
bitstream_name=$2
device_index=$4
vivado_version=$6

#constants
SERVERADDR="localhost"
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)

#derived
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get email
email=$($CLI_PATH/common/get_email)

echo "${bold}sgutil program vivado${normal}"
echo ""

#get virtualized
virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)

#get serial number
serial_number=$($CLI_PATH/get/get_fpga_device_param $device_index serial_number)

#get device name
device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

echo "${bold}Programming bitstream:${normal}"
$VIVADO_PATH/$vivado_version/bin/vivado -nolog -nojournal -mode batch -source $CLI_PATH/program/flash_bitstream.tcl -tclargs $SERVERADDR $serial_number $device_name $bitstream_name

#check for virtualized and apply pci_hot_plug (is always needed as we reverted first)
if [ "$virtualized" = "1" ] && [[ $(lspci | grep Xilinx | wc -l) = 2 ]]; then
    echo ""
    echo "${bold}The server needs to warm boot to operate in Vivado workflow. For this purpose:${normal}"
    echo ""
    echo "    Use the ${bold}go to baremetal${normal} button on the booking system, or"
    echo "    Contact ${bold}$email${normal} for support."
    echo ""
    #send email
    echo "Subject: $USER requires to go to baremetal/warm boot ($hostname)" | sendmail $email
    exit
elif [ "$virtualized" = "0" ]; then 
    #get device params
    upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
    root_port=$($CLI_PATH/get/get_fpga_device_param $device_index root_port)
    LinkCtl=$($CLI_PATH/get/get_fpga_device_param $device_index LinkCtl)
    #hot plug boot
    sudo $CLI_PATH/program/pci_hot_plug 1 $upstream_port $root_port $LinkCtl
    #print
    bdf="${upstream_port%??}" #i.e., we transform 81:00.0 into 81:00
fi

#author: https://github.com/jmoya82