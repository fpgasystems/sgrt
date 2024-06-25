#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
servers=("${@:2}")

# create key
echo "${bold}Creating id_rsa private and public keys:${normal}"
echo ""
FILE="/home/$USER/.ssh/id_rsa.pub"
if ! [ -f "$FILE" ]; then
    #create key
	echo ""
    eval "ssh-keygen"

    #remove from known hosts
    #ssh-keygen -R $hostname

    #add id_rsa.pub to authorized_keys 
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

    echo ""
    echo "Done!"
    echo ""
else
    echo "The key already exists."
    echo ""
fi

if [ ${#servers[@]} -ne 0 ]; then
    ## add SSH (mellanox-0) fingerprints to local known_hosts
    echo "${bold}Adding fingerprints to known_hosts:${normal}"
    
    #alveo-build-01
    #ssh-keygen -R alveo-build-01-mellanox-0
    #ssh-keyscan -H alveo-build-01-mellanox-0 >> ~/.ssh/known_hosts #> /dev/null

    #booked servers
    for i in "${servers[@]}"
    do
        echo ""
        ssh-keygen -R $i-mellanox-0
        ssh-keyscan -H $i-mellanox-0 >> ~/.ssh/known_hosts #> /dev/null
        sleep 1
    done
    echo ""
fi
