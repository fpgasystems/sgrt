#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
COLOR_XILINX=$2
COLOR_OFF=$3

echo ""
echo -e "${bold}${COLOR_XILINX}$CLI_NAME program vivado [flags] [--help]${COLOR_OFF}${normal}"
echo ""
echo -e "${COLOR_XILINX}Programs a Vivado bitstream to a given device.${COLOR_OFF}"
echo ""
echo "FLAGS:"
echo "   ${bold}-b, --bitstream${normal} - Full path to the .bit bitstream to be programmed." 
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to program a bitstream."
echo ""