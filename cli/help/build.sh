#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_acap=$2
is_cpu=$3
is_fpga=$4
is_gpu=$5

echo ""
echo "${bold}$CLI_NAME build [arguments [flags]] [--help]${normal}"
echo ""
echo "Creates binaries, bitstreams, and drivers for your accelerated applications."
echo ""
echo "ARGUMENTS:"
if                         [ "$is_cpu" = "1" ] ||                         [ "$is_gpu" = "1" ]; then
echo "   hip             - Generates HIP binaries for your projects."  
fi
if [ "$is_acap" = "1" ] || [ "$is_cpu" = "1" ] || [ "$is_fpga" = "1" ]                       ; then
echo "   opennic         - Generates OpenNIC's bitstreams and drivers."
fi
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
exit 1