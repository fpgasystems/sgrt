#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
DIR=$1
COMMIT=$2

#constants
ONIC_REPO="https://github.com/Xilinx/open-nic-shell.git"

#print
#echo "" Javi (28.05.2024): never before!
echo "${bold}Checking out OpenNIC:${normal}"
echo ""

#change directory
cd $DIR

# Clone the repository
git clone $ONIC_REPO #https://github.com/fpgasystems/Coyote.git

# Change to the repository directory
cd open-nic-shell

# Checkout the specific commit in the main branch
git checkout $COMMIT > /dev/null 2>&1

echo ""
echo "Checkout commit ID ${bold}$COMMIT${normal} done!"
echo ""

# Change back to the original directory
cd $DIR

#move
mv open-nic-shell/* .
rm -rf open-nic-shell