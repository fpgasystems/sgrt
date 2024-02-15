#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g config_found="0"
declare -g config_name=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -c " ]] || [[ " ${flags[$i]} " =~ " --config " ]]; then
        config_found="1"
        project_idx=$(($i+1))
        config_name=${flags[$project_idx]}
    fi
done

#return the values
echo "$config_found"
echo "$config_name"