#!/bin/bash

eno_onic=$1
IP0=$2
netmask=$3

sudo ifconfig $eno_onic down
sleep 2
sudo ifconfig $eno_onic $IP0 netmask $netmask
sudo ifconfig $eno_onic up
sleep 2

# Verify if the IP address is set correctly, reapply if necessary
#current_ip=$(ifconfig $eno_onic | grep 'inet ' | awk '{print $2}')
#if [ "$current_ip" != "$IP0" ]; then
    echo "IP address was not set correctly, reapplying..."
#    sudo ifconfig $eno_onic $IP0 netmask $netmask
#    sudo ifconfig $eno_onic up
#fi