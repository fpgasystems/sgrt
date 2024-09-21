#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"


lscpu