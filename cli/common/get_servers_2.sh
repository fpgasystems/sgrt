#!/bin/bash

CLI_PATH=$1
SERVER_LIST=$2
hostname=$3
username=$4

test_ssh_access() {
    username="$1"
    server="$2"
    /usr/bin/ssh -q -o BatchMode=yes -o ConnectTimeout=5 "$username@$server" exit
    if [ $? -eq 0 ]; then
        return 0  # SSH access is successful
    else
        return 1  # SSH access failed
    fi
}

# Declare global variables
declare -g servers_family_list=""
declare -g servers_family_list_string=""

# Read server names from the SERVER_LIST file into an array
#mapfile -t servers < $SERVER_LIST

#echo "New server list:"
#echo $SERVER_LIST

# Convert string to an array
SERVER_LIST=($SERVER_LIST)

#get booked machines
#servers_old=$(sudo $CLI_PATH/common/get_booking_system_servers_list | tail -n +2)

#echo "Servers old:" ===> hacc-box-02 hacc-box-03 hacc-box-01
#echo $servers_old

#Loop through the server list and test SSH access
#servers=""
servers=()
for server in "${SERVER_LIST[@]}"; do
    if test_ssh_access "$username" "$server"; then
        #servers+=" $server"
        #echo "$server = Yes!"
        servers+=("$server") 
    fi
done

#echo "Additional for loop - begin"
#for i in "${servers[@]}"; do
#    echo $i
#done
#echo "Additional for loop - end"

# Convert string to an array
#servers_old=($servers_old)
#servers=($servers)

#echo "servers_old: $servers_old"
#echo "servers: $servers"

#exit

# We only show likely servers (i.e., alveo-u55c)
server_family="${hostname%???}"

# Build servers_family_list
servers_family_list=()
for i in "${servers[@]}"; do
    #echo "server $i"
    if [[ $i == $server_family* ]] && [[ $i != $hostname ]]; then
        # Append the matching element to the array
        servers_family_list+=("$i") 
        #echo " added."
    fi
done

#echo $servers_family_list

#exit

#convert to string and remove the leading delimiter (:2)
servers_family_list_string=$(printf ", %s" "${servers_family_list[@]}")
servers_family_list_string=${servers_family_list_string:2}
  
# Return the array
echo "${servers_family_list[@]}"
echo "${servers_family_list_string[@]}"