#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
DIR=$1
COMMIT_SHELL=$2
COMMIT_DRIVER=$3

#constants
ONIC_REPO_SHELL="https://github.com/Xilinx/open-nic-shell.git"
ONIC_REPO_DRIVER="https://github.com/Xilinx/open-nic-driver.git"

#print
#echo "" Javi (28.05.2024): never before!
echo "${bold}Checking out OpenNIC shell:${normal}"
echo ""

#change directory
cd $DIR

# Clone shell repository
git clone $ONIC_REPO_SHELL #https://github.com/fpgasystems/Coyote.git

# Change to the repository directory
cd open-nic-shell

# Checkout the specific commit in the main branch
git checkout $COMMIT_SHELL > /dev/null 2>&1

#echo ""
#echo "Checkout commit ID (shell) ${bold}$COMMIT_SHELL${normal} done!"
#echo ""

# Change back to the original directory
cd $DIR

#move
mv open-nic-shell/* .
rm -rf open-nic-shell

echo ""
echo "${bold}Checking out OpenNIC driver:${normal}"
echo ""

# Clone driver repository
git clone $ONIC_REPO_DRIVER

# Change to the repository directory
cd open-nic-driver

# Checkout the specific commit in the main branch
git checkout $COMMIT_DRIVER > /dev/null 2>&1

echo ""
echo "Checkout commit ID (shell and driver) ${bold}$COMMIT_SHELL,$COMMIT_DRIVER${normal} done!"
echo ""