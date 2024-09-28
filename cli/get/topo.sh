#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)

#set temporal writing directory
TMP_PATH=$(echo "$MY_DRIVERS_PATH" | awk -F'/' '{print "/"$2}')

#remove all previous files
sudo $CLI_PATH/common/rm $TMP_PATH/numa_*

# Capture the number of NUMA nodes
numa_nodes=$(lscpu | grep -i "NUMA node(s)" | awk '{print $NF}')

# Get the required fields: Model name, Frequency boost, CPU MHz, CPU max MHz, CPU min MHz, and NUMA node CPU(s)
model_name=$(lscpu | grep -i "Model name" | awk -F: '{print $2}' | xargs)
freq_boost=$(lscpu | grep -i "Frequency boost" | awk -F: '{print $2}' | xargs)
cpu_mhz=$(lscpu | grep -i "CPU MHz" | awk -F: '{print $2}' | xargs)
cpu_max_mhz=$(lscpu | grep -i "CPU max MHz" | awk -F: '{print $2}' | xargs)
cpu_min_mhz=$(lscpu | grep -i "CPU min MHz" | awk -F: '{print $2}' | xargs)

# Loop through each NUMA node and create a corresponding file
for ((i=0; i<numa_nodes; i++)); do
    # Get the CPUs for the current NUMA node
    numa_cpus=$(lscpu | grep -i "NUMA node${i} CPU(s)" | awk -F: '{print $2}' | xargs)

    # Create a file for each NUMA node
    file_name="$TMP_PATH/numa_$((i+1))"
    echo "$model_name" > $file_name
    echo "" > $file_name
    echo "NUMA node ${i} CPU(s): $numa_cpus" >> $file_name
    echo "    CPU MHz: $cpu_mhz" >> $file_name
    echo "    CPU max MHz: $cpu_max_mhz" >> $file_name
    echo "    CPU min MHz: $cpu_min_mhz" >> $file_name
    echo "    Frequency boost: $freq_boost" >> $file_name
    #echo "File $file_name created with NUMA node ${i} details."
done

#echo "Script execution completed."