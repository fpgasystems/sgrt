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
echo "${bold}Checking out OpenNIC shell:${normal}"
echo ""

#change directory
cd $DIR

#clone shell repository
git clone $ONIC_REPO_SHELL

#change to repository directory
cd $DIR/open-nic-shell

#checkout the specific commit in the main branch
git checkout $COMMIT_SHELL > /dev/null 2>&1

#remove the repository (in case we add it later to our own repository)
rm -rf .git

echo ""
echo "${bold}Checking out OpenNIC driver:${normal}"
echo ""

#change back to the original directory
cd $DIR

#clone driver repository
git clone $ONIC_REPO_DRIVER

#change to repository directory
cd $DIR/open-nic-driver

# Checkout the specific commit in the main branch
git checkout $COMMIT_DRIVER > /dev/null 2>&1

#remove the repository (in case we add it later to our own repository)
rm -rf .git

echo ""
echo "Checkout commit ID (shell and driver) ${bold}$COMMIT_SHELL,$COMMIT_DRIVER${normal} done!"
echo ""