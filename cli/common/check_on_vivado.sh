#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
CLI_PATH=$1
VIVADO_PATH=$2
hostname=$3
vivado_version=$4

#vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
if [ -n "$vivado_version" ]; then
    #vivado_version is not empty and we check if the Vivado directory exists
    if [ ! -d $VIVADO_PATH/$vivado_version ]; then
        echo ""
        echo "Please, choose a valid Vivado version for ${bold}$hostname!${normal}"
        echo ""
        exit 1
    fi
else
    #vivado_version is empty and we set the more recent Vivado version by default
    vivado_version=$(find "$VIVADO_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -V | tail -n 1)

    #vivado_version and VIVADO_PATH are empty
    if [ -z "$vivado_version" ]; then
        echo ""
        echo "Please, source a valid Vivado version for ${bold}$hostname!${normal}"
        echo ""
        exit 1
    fi
fi