#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$0")"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get username
username=$USER

# inputs
read -a flags <<< "$@"

echo ""
echo "${bold}sgutil program reboot${normal}"

#check on ACAP or FPGA servers (server must have at least one ACAP or one FPGA - reboot excluded on build-servers)
acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit
fi

#check for vivado_developers
member=$($CLI_PATH/common/is_member $username vivado_developers)
if [ "$member" = "false" ]; then
    echo ""
    echo "Sorry, ${bold}$username!${normal} You are not granted to use this command."
    echo ""
    exit
fi

echo ""
echo "The server will reboot (warm boot) in 3 seconds."
sleep 1
echo "The server will reboot (warm boot) in 2 seconds.."
sleep 1
echo "The server will reboot (warm boot) in 1 seconds..."
sleep 1
echo ""
echo "See you later, ${bold}$username!${normal}"
echo ""

sudo reboot