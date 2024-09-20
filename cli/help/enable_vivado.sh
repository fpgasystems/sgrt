#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_cpu=$2

if [ "$is_cpu" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME enable vivado [--help]${normal}"
    echo ""
    echo "Enables Vivado HDI (Hardware Design and Implementation)."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
fi