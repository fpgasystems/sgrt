#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo ""
echo "${bold}$CLI_NAME program reset [flags] [--help]${normal}"
echo ""
echo "Performs a 'HOT Reset' on a Vitis device."
echo ""
echo "FLAGS:"
echo "   -d, --device    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo ""
echo "   -h, --help      - Help to use this command."
echo ""