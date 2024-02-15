#!/bin/bash

#username=$1
#workflow=$2

MY_PROJECT_PATH=$1

# Declare global variables
declare -g config_found="0"
declare -g config_name=""

#get configs
cd $MY_PROJECT_PATH/configs/
configs=( "config_"* )

#remove selected files
configs_aux=()
for element in "${configs[@]}"; do
    if [[ $element != *"config_parameters"* && $element != *.hpp ]]; then #config_000 && $element != *.active
        configs_aux+=("$element")
    fi
done

# Check if there is only one directory
if [ ${#configs_aux[@]} -eq 1 ]; then
    config_found="1"
    config_name=${configs_aux[0]}
else
    PS3=""
    select config_id in "${configs_aux[@]}"; do
        if [[ -z $config_id ]]; then
            echo "" >&/dev/null
        else
            break
        fi
    done
fi

# Return the values of config_found and config_name
echo "$config_found"
echo "$config_name"