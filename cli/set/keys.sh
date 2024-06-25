#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/set/keys
#example: /opt/sgrt/cli/set/keys

#combine CPU, ACAP and FPGA lists removing duplicates
mapfile -t SERVER_LIST < <(sort -u "$CLI_PATH/constants/CPU_SERVERS_LIST" "$CLI_PATH/constants/ACAP_SERVERS_LIST" "$CLI_PATH/constants/FPGA_SERVERS_LIST")

echo "${bold}sgutil set keys${normal}"
echo "" 

#setup keys
$CLI_PATH/common/ssh_key_add $CLI_PATH "${SERVER_LIST[@]}"

#author: https://github.com/jmoya82