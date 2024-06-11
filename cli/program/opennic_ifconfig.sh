#!/bin/bash

eno_onic=$1
mac_address=$2
IP0=$3
netmask=$4

#constants
NUM_ATTEMPTS=3

# Define a function to check if the IP address is set correctly
check_ip() {
    current_ip=$(ifconfig $eno_onic | grep 'inet ' | awk '{print $2}')
    [ "$current_ip" != "$IP0" ]
}

sudo ifconfig $eno_onic down
sleep 3
sudo ifconfig $eno_onic hw ether $mac_address
sudo ifconfig $eno_onic $IP0 netmask $netmask
sudo ifconfig $eno_onic up
sleep 3

# Loop for NUM_ATTEMPTS
for ((attempt=1; attempt<=NUM_ATTEMPTS; attempt++)); do
    if check_ip; then
        #if [ $attempt -eq 1 ]; then
        #    echo "IP address was not set correctly, reapplying..."
        #fi
        sudo ifconfig $eno_onic hw ether $mac_address
        sudo ifconfig $eno_onic $IP0 netmask $netmask
        sudo ifconfig $eno_onic up
        sleep 2  # Adding delay to ensure the interface comes up
    else
        break  # Exit the loop if the IP address is set correctly
    fi
done