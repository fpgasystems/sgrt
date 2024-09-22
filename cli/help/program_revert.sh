#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
COLOR_XILINX=$2
COLOR_OFF=$3

echo "" #this one is needed
echo -e "${bold}${COLOR_XILINX}$CLI_NAME program revert [flags] [--help]${COLOR_OFF}${normal}"
echo ""
echo -e "${COLOR_XILINX}Returns a device to its default fabric setup.${COLOR_OFF}"
echo ""
echo "FLAGS:"
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to revert a device."
echo ""