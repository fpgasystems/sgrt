#!/bin/bash

CLI_PATH="$(dirname "$0")"
bold=$(tput bold)
normal=$(tput sgr0)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#early exit
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_sudo=$($CLI_PATH/common/is_sudo $USER)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$is_sudo" != "1" ] && ! ([ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]); then
    exit 1
fi

# inputs
#read -a flags <<< "$@"

echo ""
#echo "${bold}sgutil reboot${normal}"

#check on ACAP or FPGA servers (server must have at least one ACAP or one FPGA - reboot excluded on build-servers)
#acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
#fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
#if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
#    echo ""
#    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
#    echo ""
#    exit
#fi

#check for vivado_developers
#member=$($CLI_PATH/common/is_member $USER vivado_developers)
#if [ "$member" = "0" ]; then
#    echo ""
#    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
#    echo ""
#    exit
#fi

#Loop for countdown
for i in {30..0}; do
    echo -n "."
    sleep 0.5
done

# Print the final message after countdown
echo ""
echo -e "\nSee you later, ${bold}$USER!${normal}"
echo ""

sudo reboot