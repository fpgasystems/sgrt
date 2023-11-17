#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#print message
echo ""
echo "Please type ${bold}source $CLI_PATH/set/license${normal} to set your favorite Xilinx license server"
echo ""