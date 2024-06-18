#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
DIR=$1
COYOTE_COMMIT=$2

#print
echo "${bold}Checking out Coyote:${normal}"
echo ""

#change directory
cd $DIR

#clone repository
git clone https://github.com/fpgasystems/Coyote.git

#change to repository directory
cd $DIR/Coyote

#checkout the specific commit in the main branch
git checkout $COYOTE_COMMIT > /dev/null 2>&1

#remove the repository (in case we add it later to our own repository)
rm -rf .git

echo ""
echo "Checkout commit ID ${bold}$COYOTE_COMMIT${normal} done!"
echo ""

#move directory
cd $DIR
mv Coyote/* .
rm -rf Coyote