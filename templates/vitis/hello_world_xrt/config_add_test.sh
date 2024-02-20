#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

get_config_id() {
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

generate_selectable_values() {
    local min="$1"
    local max="$2"
    local inc="$3"

    # Initialize an empty array for selectable values
    local selectable_values=()

    # Loop from min to max with increments of inc and add each value to the array
    for ((value = min; value <= max; value += inc)); do
        selectable_values+=("$value")
    done

    # Print the selectable values separated by spaces
    echo "${selectable_values[*]}"
}

validate_input() {
    
    #get inputs
    local input="$1"
    local selectable_values="$2"

    #check if the input is one of the selectable values
    for value in $selectable_values; do
        if [[ "$input" == "$value" ]]; then
            echo "$input"
            return 0
        fi
    done

    #print an error message (if wanted)
    return 1
}

add_to_config_file() {
    local config_id="$1"
    local parameter_i="$2"
    local selected_value="$3"

    # Append the parameter and its selected value to the configuration file
    echo "$parameter_i = $selected_value;" >> "$MY_PROJECT_PATH/configs/$config_id"
}

#constants
MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"

#to be deleted
rm $MY_PROJECT_PATH/configs/config_parameters
rm $MY_PROJECT_PATH/configs/kernel*

#get config_id
config_id=$(get_config_id $MY_PROJECT_PATH)

#create kernel_parameters.hpp
touch $MY_PROJECT_PATH/configs/kernel_parameters.hpp

#create configuration file
touch $MY_PROJECT_PATH/configs/$config_id

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
                inc="1"
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

            # Generate selectable values
            selectable_values=$(generate_selectable_values "$min" "$max" "$inc")

            #prompt the user to choose one of the selectable values
            read -rp "$parameter_i [$selectable_values]: " selected_value
            
            #validate user input
            while ! validate_input "$selected_value" "$selectable_values"; do
                read -rp "$parameter_i [$selectable_values]: " selected_value
            done
            
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

    #add to config_id
    add_to_config_file "$config_id" "$parameter_i" "$selected_value"

    #add to kernel_parameters.hpp (when it contains the suffix _MAX)
    if [[ "$parameter_i" == *_MAX* ]]; then
        add_to_config_file "kernel_parameters.hpp" "const int $parameter_i" "$selected_value"
    fi

done