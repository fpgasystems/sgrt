#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo ""
echo "${bold}$CLI_NAME program vivado [flags] [--help]${normal}"
echo ""
echo "Programs a Vivado bitstream to a given device."
echo ""
echo "FLAGS:"
echo "   -b, --bitstream - Full path to the .bit bitstream to be programmed." 
echo "   -d, --device    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo ""
echo "   -h, --help      - Help to program a bitstream."
echo ""