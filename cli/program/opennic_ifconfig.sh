#!/bin/bash

eno_onic=$1
mac_address=$2
IP0=$3
netmask=$4

#constants
NUM_ATTEMPTS=3
UNMANAGED_DEVICES_FILE="/etc/NetworkManager/conf.d/99-unmanaged-devices.conf"

#define a function to check if the IP address is set correctly
check_ip() {
    current_ip=$(ifconfig $eno_onic | grep 'inet ' | awk '{print $2}')
    [ "$current_ip" != "$IP0" ]
}

#convert the MAC address to lowercase
mac_address=$(echo "$mac_address" | tr '[:upper:]' '[:lower:]')

#update NetworkManager (set interface as unmanaged)
device_to_add="unmanaged-devices=interface-name:$eno_onic"
if [ ! -e "$UNMANAGED_DEVICES_FILE" ]; then
    #create the file and add the device
    echo -e "[keyfile]\n$device_to_add" > "$UNMANAGED_DEVICES_FILE"
    #reload NetworkManager
    sudo systemctl reload NetworkManager
elif ! grep -qF "$device_to_add" "$UNMANAGED_DEVICES_FILE"; then
    #if the line does not existe in the file, append it at the end
    echo "$device_to_add" >> "$UNMANAGED_DEVICES_FILE"
    #reload NetworkManager
    sudo systemctl reload NetworkManager
fi

#set IP with ifconfig (1/2)
sudo ifconfig $eno_onic down
sleep 3
sudo ifconfig $eno_onic hw ether $mac_address
sudo ifconfig $eno_onic $IP0 netmask $netmask
sudo ifconfig $eno_onic up
sleep 3

#loop for NUM_ATTEMPTS
for ((attempt=1; attempt<=NUM_ATTEMPTS; attempt++)); do
    if check_ip; then
        sudo ifconfig $eno_onic hw ether $mac_address
        sudo ifconfig $eno_onic $IP0 netmask $netmask
        sudo ifconfig $eno_onic up
        sleep 2  # Adding delay to ensure the interface comes up
    else
        break  # Exit the loop if the IP address is set correctly
    fi
done