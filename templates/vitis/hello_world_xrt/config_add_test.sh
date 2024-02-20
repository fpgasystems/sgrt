#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

get_config_id(){
    #change directory
    CONFIGS_PATH=$1/configs
    cd $CONFIGS_PATH
    #get configs
    configs=( "config_"* )
    #get the last configuration name
    last_config="${configs[-1]}"
    #extract the number part of the configuration name
    number_part="${last_config#*_}"
    number=$(printf "%03d" $((10#$number_part + 1)))  # Increment the number and format it as 3 digits with leading zeros
    #construct the new configuration name
    config_id="config_$number"
    #change back directory
    cd ..
    #return
    echo $config_id
}

#constants
MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
#TEMPLATE="vadd"

#change to project directory
#cd $MY_PROJECT_PATH

#get config_id
#cd $MY_PROJECT_PATH/configs/
#to be deleted
rm $MY_PROJECT_PATH/configs/config_parameters
rm $MY_PROJECT_PATH/configs/kernel*
#...
#configs=( "config_"* )

# Get the last configuration name
#last_config="${configs[-1]}"

# Extract the number part of the configuration name
#number_part="${last_config#*_}"
#number=$(printf "%03d" $((10#$number_part + 1)))  # Increment the number and format it as 3 digits with leading zeros

# Construct the new configuration name
#config_id="config_$number"

#echo $config_id


#change to project directory
#cd $MY_PROJECT_PATH

#get config_id
config_id=$(get_config_id $MY_PROJECT_PATH)

echo $config_id

#change to project directory
#cd $MY_PROJECT_PATH

#echo $MY_PROJECT_PATH

#read from parameters
declare -a parameters
declare -a descriptions
declare -a ranges

while read -r line; do
    column_1=$(echo "$line" | awk '{print $1}')
    column_2=$(echo "$line" | awk '{print $2}')
    column_3=$(echo "$line" | awk '{print $3}')
    parameters+=("$column_1")
    ranges+=("$column_2")
    descriptions+=("$column_3")
done < "$MY_PROJECT_PATH/parameters"

for ((i = 0; i < ${#parameters[@]}; i++)); do
    # Map to parameters
    parameter_i="${parameters[i]}"
    ranges_i="${ranges[i]}"

    min=""
    max=""
    inc=""
    list=""
    constant=""
    case "$ranges_i" in
        *:*)
            colon_count=$(grep -o ":" <<< "$ranges_i" | wc -l)
            if [[ $colon_count -eq 1 ]]; then
                echo "The $parameter_i contains a single colon (:)"
                min="${ranges_i%%:*}"   # Get the part before the first colon
                max="${ranges_i#*:}"    # Get the part after the first colon
                echo "min = $min"
                echo "max = $max"
            elif [[ $colon_count -eq 2 ]]; then
                echo "The $parameter_i contains two colons (:)"
                min="${ranges_i%%:*}"          # Get the part before the first colon
                remaining="${ranges_i#*:}"     # Remove the part before the first colon
                inc="${remaining%%:*}"       # Get the part between the first and second colons
                max="${remaining#*:}"        # Get the part after the second colon
                echo "min = $min"
                echo "inc = $inc"
                echo "max = $max"
            fi
            ;;
        *","*)
            echo "The $parameter_i contains one or more single quotes (,)"
            ;;
        *)
            echo "The $parameter_i is a string without any colon (:), comma (,), or any other specified character"
            constant=$ranges_i
            echo "constant = $constant"
            ;;
    esac
done