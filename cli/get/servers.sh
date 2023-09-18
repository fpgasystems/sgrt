#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#combine ACAP and FPGA lists removing duplicates
SERVER_LIST=$(sort -u $CLI_PATH/constants/ACAP_SERVERS_LIST /$CLI_PATH/constants/FPGA_SERVERS_LIST)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get username
username=$USER

#get servers
result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
#num_remote_servers=$(echo "$servers_family_list" | wc -w)

#print
if [ -n "${servers_family_list[@]}" ]; then
    server_index=1
    echo ""
    for server in "${servers_family_list[@]}"; do
        echo "$server_index: $server"
        ((server_index++))
    done
    echo ""
fi