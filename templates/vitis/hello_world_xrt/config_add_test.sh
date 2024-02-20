#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
MAX_PROMPT_ELEMENTS=10

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
    if [[ -n "$selected_value" ]]; then
        echo "$parameter_i = $selected_value;" >> "$MY_PROJECT_PATH/configs/$config_id"
    fi
}

find_existing_parameter() {
    local parameter_i="$1"

    # Loop through the parameters_aux array
    for parameter_value in "${parameters_aux[@]}"; do
        # Extract the parameter name and value from each element
        parameter_name="${parameter_value%% = *}"
        value="${parameter_value#* = }"

        # Check if the parameter name matches the specified parameter_i
        if [[ "$parameter_name" == "$parameter_i" ]]; then
            # If a match is found, return the corresponding value
            echo "$value"
            return 0
        fi
    done

    # If the parameter is not found or doesn't contain letters, return an empty string ==> return $max $min $inc
    echo "$1"
    return 1
}

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

#store already declared parameters
declare -a parameters_aux

#create configuration
for ((i = 0; i < ${#parameters[@]}; i++)); do
    
    #map to parameters
    parameter_i="${parameters[i]}"
    ranges_i="${ranges[i]}"

    min=""
    max=""
    inc=""
    list=""
    constant=""
    selectable_values=""
    selected_value=""
    case "$ranges_i" in
        *:*)
            colon_count=$(grep -o ":" <<< "$ranges_i" | wc -l)
            if [[ $colon_count -eq 1 ]]; then
                #echo "The $parameter_i contains a single colon (:)"
                min="${ranges_i%%:*}"   # Get the part before the first colon
                inc="1"
                max="${ranges_i#*:}"    # Get the part after the first colon
                #echo "min = $min"
                #echo "max = $max"
            elif [[ $colon_count -eq 2 ]]; then
                #echo "The $parameter_i contains two colons (:)"
                min="${ranges_i%%:*}"          # Get the part before the first colon
                remaining="${ranges_i#*:}"     # Remove the part before the first colon
                inc="${remaining%%:*}"       # Get the part between the first and second colons
                max="${remaining#*:}"        # Get the part after the second colon
                #echo "min = $min"
                #echo "inc = $inc"
                #echo "max = $max"
            fi

            #replace already declared
            echo "Before: $max / $inc / $min"
            min=$(find_existing_parameter $min)
            inc=$(find_existing_parameter $inc)
            max=$(find_existing_parameter $max)
            echo "After: $max / $inc / $min"

            #generate selectable values
            selectable_values=$(generate_selectable_values "$min" "$max" "$inc")

            #get prompt
            num_elements=$(echo "$selectable_values" | wc -w)

            echo "Num elements: $num_elements"

            #check if the number of elements is more than 10
            if (( num_elements > $MAX_PROMPT_ELEMENTS )); then
                echo "More than 10"
                echo "INC is $inc"
                if [[ "$inc" == "1" ]]; then
                    selectable_values_prompt="$min .. $max"
                else
                    selectable_values_prompt="$min:$inc:$max"
                fi
            else
                echo "Less than 10"
                selectable_values_prompt=$selectable_values
            fi    
            
            ;;
        *","*)
            #echo "The $parameter_i contains one or more single quotes (,)"

            # Generate selectable values
            selectable_values=$(echo "$ranges_i" | tr "," " ")

            ;;
        *)
            #echo "The $parameter_i is a string without any colon (:), comma (,), or any other specified character"
            constant=$ranges_i
            echo "constant = $constant"
            ;;
    esac

    #prompt the user to choose one of the selectable values
    read -rp "$parameter_i [$selectable_values_prompt]: " selected_value
    
    #validate user input
    while ! validate_input "$selected_value" "$selectable_values"; do
        read -rp "$parameter_i [$selectable_values_prompt]: " selected_value
    done

    #add to kernel_parameters.hpp or config_id
    if [[ "$parameter_i" == *_MAX* ]]; then
        #it contains the suffix _MAX (assumed as a xclbin parameter)
        add_to_config_file "kernel_parameters.hpp" "const int $parameter_i" "$selected_value"
    else
        #assumed as a host parameter
        add_to_config_file "$config_id" "$parameter_i" "$selected_value"
    fi


    #echo "Adding $parameter_i = $selected_value"

    #save already declared
    parameters_aux+=("$parameter_i = $selected_value")

    #printing all values
    #echo "print"
    #for value in "${parameters_aux[@]}"; do
    #    echo "$value"
    #done
    #echo "print done"

done