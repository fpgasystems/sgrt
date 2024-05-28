#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
DIR=$1
COYOTE_COMMIT=$2

#constants
#COYOTE_COMMIT="4629886"

#print
#echo "" Javi (28.05.2024): never before!
echo "${bold}Checking out Coyote:${normal}"
echo ""

#change directory
cd $DIR

# Clone the repository
git clone https://github.com/fpgasystems/Coyote.git

# Change to the repository directory
cd Coyote

# Checkout the specific commit in the main branch
git checkout $COYOTE_COMMIT > /dev/null 2>&1

echo ""
echo "Checkout commit ID ${bold}$COYOTE_COMMIT${normal} done!"
echo ""

# Change back to the original directory
cd $DIR

#move
mv Coyote/* .
rm -rf Coyote