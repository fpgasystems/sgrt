#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)

#derived
ADAPTABLE_DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
GPU_DEVICES_LIST="$CLI_PATH/devices_gpu"
TMP_PATH=$(echo "$MY_DRIVERS_PATH" | awk -F'/' '{print "/"$2}')

#legend
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON3=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_ACAP)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

function get_numa_node() {
    local pci_device="$1"
    local lstopo_output="$TMP_PATH/lstopo_output"  # Replace this with the actual file or command to get the output.

    # Check if the PCI device exists in the output
    if ! grep -q "PCI $pci_device" "$lstopo_output"; then
        echo "PCI device $pci_device not found."
        return 1
    fi

    # Extract the part of the file from the PCI device upwards
    local section=$(tac "$lstopo_output" | sed -n "/PCI $pci_device/,/NUMANode L#[0-9]/p" | tac)

    # Find which NUMA node is closest
    local numa_node=$(echo "$section" | grep -m1 -o 'NUMANode L#[01]')

    numa_node_value="${numa_node#*#}"
    echo "$numa_node_value"

}

# Example usage:
# get_numa_node "81:00.0"





#get devices lists
MAX_ADAPTABLE_DEVICES=""
MAX_GPU_DEVICES=""
if [ -s "$ADAPTABLE_DEVICES_LIST" ]; then
    source "$CLI_PATH/common/device_list_check" "$ADAPTABLE_DEVICES_LIST"
    MAX_ADAPTABLE_DEVICES=$($CLI_PATH/common/get_max_devices "fpga|acap|asoc" $ADAPTABLE_DEVICES_LIST)
fi
if [ -s "$GPU_DEVICES_LIST" ]; then
    source "$CLI_PATH/common/device_list_check" "$GPU_DEVICES_LIST"
    MAX_GPU_DEVICES=$($CLI_PATH/common/get_max_devices "gpu" $GPU_DEVICES_LIST)
fi

#remove first
sudo $CLI_PATH/common/rm $TMP_PATH/lstopo_output

#create temporal output
lstopo 2>/dev/null > $TMP_PATH/lstopo_output

# Capture the number of NUMA nodes
numa_nodes=$(lscpu | grep -i "NUMA node(s)" | awk '{print $NF}')

#lscpu
model_name=$(lscpu | grep -i "Model name" | awk -F: '{print $2}' | xargs)
cpu_count=$(lscpu | grep -i "^CPU(s):" | awk '{print $2}')
online_cpus=$(lscpu | grep -i "On-line CPU(s) list" | awk -F: '{print $2}' | xargs)
threads_per_core=$(lscpu | grep -i "Thread(s) per core" | awk -F: '{print $2}' | xargs)
cores_per_socket=$(lscpu | grep -i "Core(s) per socket" | awk -F: '{print $2}' | xargs)
freq_boost=$(lscpu | grep -i "Frequency boost" | awk -F: '{print $2}' | xargs)
cpu_mhz=$(lscpu | grep -i "CPU MHz" | awk -F: '{print $2}' | xargs)
cpu_max_mhz=$(lscpu | grep -i "CPU max MHz" | awk -F: '{print $2}' | xargs)
cpu_min_mhz=$(lscpu | grep -i "CPU min MHz" | awk -F: '{print $2}' | xargs)

echo "" #> $file_name
echo "$model_name" #>> $file_name
echo "CPU(s): $cpu_count" #>> $file_name
echo "On-line CPU(s) list: $online_cpus" #>> $file_name
echo "Thread(s) per core: $threads_per_core" #>> $file_name
echo "Core(s) per socket: $cores_per_socket" #>> $file_name

# Loop through each NUMA node and create a corresponding file
for ((i=0; i<numa_nodes; i++)); do
    # Get the CPUs for the current NUMA node
    numa_cpus=$(lscpu | grep -i "NUMA node${i} CPU(s)" | awk -F: '{print $2}' | xargs)
    memory=$(lstopo 2>/dev/null | grep -i "NUMANode L#$i" | awk -F'[()]' '{print $2}' | awk '{print $NF}')

    # Create a file for each NUMA node
    #file_name="$TMP_PATH/numa_$((i+1))"
    
    echo "" #>> $file_name
    #echo "NUMA node $(( i + 1 )) CPU(s): $numa_cpus" #>> $file_name
    echo "NUMA node $i CPU(s): $numa_cpus" #>> $file_name
    echo "    CPU MHz: $cpu_mhz" #>> $file_name
    echo "    CPU max MHz: $cpu_max_mhz" #>> $file_name
    echo "    CPU min MHz: $cpu_min_mhz" #>> $file_name
    echo "    Frequency boost: $freq_boost" #>> $file_name
    echo "    Memory: $memory" #>> $file_name
    
    #echo "CLI_PATH: $CLI_PATH"    
    #adaptive devices
    for ((j=1; j<=MAX_ADAPTABLE_DEVICES; j++)); do
        upstream_port=$($CLI_PATH/get/get_fpga_device_param $j upstream_port)
        numa_node=$(get_numa_node "$upstream_port")

        #print list
        if [ "$numa_node" = "$i" ]; then  # Correct spacing and string comparison
            if [ "$j" = "1" ]; then  # Safer with quotes
                echo ""
                echo -e "    ${bold}${COLOR_ON2}Adaptive devices${COLOR_OFF}${normal}"
            fi

            #get other parameters
            device_type=$($CLI_PATH/get/get_fpga_device_param $j device_type)

            #print
            echo "    $j: $upstream_port ($device_type)"
        fi
    done
    
     #>> $file_name
done
echo ""