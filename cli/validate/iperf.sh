#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#combine ACAP and FPGA lists removing duplicates
SERVER_LIST=$(sort -u $CLI_PATH/constants/ACAP_SERVERS_LIST /$CLI_PATH/constants/FPGA_SERVERS_LIST)

echo ""

#setup keys
eval "$CLI_PATH/common/ssh_key_add"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get username
username=$USER

#inputs
flags=$@

#replace p by P
flags=${flags/p/P}

#set default
udp_server=""
if [ "$flags" = "" ]; then
    flags="-P 4"
elif [ "$flags" = "-u" ]; then
    flags="-P 4 -u"
    udp_server=" -u"
fi

#start iperf server on local machine
echo "${bold}Starting iperf server:${normal}"
echo ""
echo "iperf -s -B $hostname-mellanox-0 -D $udp_server"
echo ""
iperf -s -B $hostname-mellanox-0 -D $udp_server
echo ""

result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p') #

#convert string to an array
servers_family_list=($servers_family_list)

#running iperf on remote machines
echo "${bold}Running iperf on remote server/s:${normal}"
echo ""
for i in "${servers_family_list[@]}"; do #servers
    if [ "$i" != "$hostname" ]; then
        echo "iperf -c $hostname-mellanox-0 -B $i-mellanox-0 $flags"
        echo ""
        ssh $i iperf -c $hostname-mellanox-0 -B $i-mellanox-0 $flags
        echo ""
    fi
done