#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
COLOR_XILINX=$2
COLOR_OFF=$3

echo ""
echo "${bold}$CLI_NAME program vivado [flags] [--help]${normal}"
echo ""
echo "Programs a Vivado bitstream or image to a given device."
echo ""
echo "FLAGS:"
#echo "   ${bold}-b, --bitstream${normal} - Full path to the .bit bitstream to be programmed." 
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}-f, --file${normal}      - Full path to the .bit bitstream or .pdi image to be programmed."
echo "   ${bold}-r, --remote${normal}    - Local or remote deployment."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to program a bitstream."
echo ""