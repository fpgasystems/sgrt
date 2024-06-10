#!/bin/bash

eno_onic=$1
IP0=$2
netmask=$3

#constants
NUM_ATTEMPTS=3

# Define a function to check if the IP address is set correctly
check_ip() {
    current_ip=$(ifconfig $eno_onic | grep 'inet ' | awk '{print $2}')
    [ "$current_ip" != "$IP0" ]
}

sudo ifconfig $eno_onic down
sleep 2
sudo ifconfig $eno_onic $IP0 netmask $netmask
sudo ifconfig $eno_onic up
sleep 2

# Loop for NUM_ATTEMPTS
for ((attempt=1; attempt<=NUM_ATTEMPTS; attempt++)); do
    if check_ip; then
        #if [ $attempt -eq 1 ]; then
        #    echo "IP address was not set correctly, reapplying..."
        #fi
        sudo ifconfig $eno_onic $IP0 netmask $netmask
        sudo ifconfig $eno_onic up
        sleep 2  # Adding delay to ensure the interface comes up
    else
        break  # Exit the loop if the IP address is set correctly
    fi
done