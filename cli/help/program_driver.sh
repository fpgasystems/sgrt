#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo ""
echo "${bold}$CLI_NAME program driver [flags] [--help]${normal}"
echo ""
echo "Inserts a driver or module into the Linux kernel."
echo ""
echo "FLAGS:"
echo "   -m, --module    - Full path to the .ko module to be inserted."
echo "   -p, --params    - A comma separated list of module parameters." 
echo ""
echo "   -h, --help      - Help to use this command."
echo ""