#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_build=$2

if [ "$is_build" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME enable [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Enables your favorite development and deployment tools on your server."
    echo ""
    echo "ARGUMENTS:"
    echo "   vitis           - Enables Vitis SDK (Software Development Kit) and Vitis_HLS (High-Level Synthesis)."
    echo "   vivado          - Enables Vivado HDI (Hardware Design and Implementation)."
    echo "   xrt             - Enables Xilinx Runtime (XRT)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
fi