#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
DIR=$1
COYOTE_COMMIT=$2

#constants
#COYOTE_COMMIT="4629886"

#print
echo ""
echo "${bold}Checking out Coyote (commit: $COYOTE_COMMIT):${normal}"
echo ""

#change directory
cd $DIR

# Clone the repository
git clone https://github.com/fpgasystems/Coyote.git

# Change to the repository directory
cd Coyote

# Checkout the specific commit in the main branch
git checkout $COYOTE_COMMIT > /dev/null 2>&1

# Change back to the original directory
cd $DIR

#move
mv Coyote/* .
rm -rf Coyote