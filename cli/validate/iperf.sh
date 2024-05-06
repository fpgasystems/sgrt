#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#combine ACAP and FPGA lists removing duplicates
SERVER_LIST=$(sort -u $CLI_PATH/constants/ACAP_SERVERS_LIST $CLI_PATH/constants/FPGA_SERVERS_LIST)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get username
username=$USER

#inputs
flags=$@

#replace -p by -P
flags=$(echo "$flags" | sed 's/-p\($\| \)/-P /g')

echo ""
echo "${bold}sgutil validate iperf${normal}"

#set default
udp_server=""
if [ "$flags" = "" ]; then
    flags="-P 4"
elif [ "$flags" = "-u" ]; then
    flags="-P 4 -u"
    udp_server=" -u"
fi

#check on flags
if [[ $flags =~ --udp\ [^'01'] || $flags =~ -u\ [^'01'] ]]; then
    $CLI_PATH/sgutil validate iperf -h
    exit
fi

# Remove "--udp 0" or "-u 0" from flags
flags=$(echo "$flags" | sed 's/\(--udp\| -u\) 0//')

# Remove "1" after "--udp" or "-u" from flags
flags=$(echo "$flags" | sed 's/\(--udp\| -u\) 1/\1/')

#get booked servers accessible with ssh
echo ""
echo "${bold}Quering remote servers with ssh:${normal}"
result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
servers_family_list_string=$(echo "$result" | sed -n '2p' | sed -n '1p')
num_remote_servers=$(echo "$servers_family_list" | wc -w)

#check on number of servers
if [ "$num_remote_servers" -eq 0 ]; then
    echo ""
    echo "Please, verify that you can ssh the targeted remote servers."
    echo ""
    exit
fi

echo ""
echo $servers_family_list_string

#convert string to an array
servers_family_list=($servers_family_list)

#setup keys
echo ""
$CLI_PATH/common/ssh_key_add $CLI_PATH "${servers_family_list[@]}"

#start iperf server on local machine
echo "${bold}Starting iperf server:${normal}"
echo ""
echo "iperf -s -B $hostname-mellanox-0 -D $udp_server"
echo ""
iperf -s -B $hostname-mellanox-0 -D $udp_server
echo ""

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