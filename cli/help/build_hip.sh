#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_cpu=$2
is_gpu=$3 

if [ "$is_cpu" = "1" ] || [ "$is_gpu" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME build hip [flags] [--help]${normal}"
    echo ""
    echo "Generates HIP binaries for your projects."
    echo ""
    echo "FLAGS:"
    echo "   -p, --project   - Specifies your HIP project name."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
fi