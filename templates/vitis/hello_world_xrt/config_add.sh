#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
MAX_PROMPT_ELEMENTS=10
INC_STEPS=2
INC_DECIMALS=2

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

generate_selectable_values_1() {
    local min="$1"
    local max="$2"
    local inc="$3"
    local precision="$INC_DECIMALS"

    # Initialize an empty array for selectable values
    local selectable_values=()

    # Initialize loop variable as floating-point number
    local value="$min"

    # Loop until the value exceeds the max
    while (( $(echo "$value <= $max" | bc -l) )); do
        # Append the value to the array
        selectable_values+=("$value")
        
        # Increment the value using bc for floating-point arithmetic
        value=$(echo "$value + $inc" | bc -l)
        value=$(printf "%.${precision}f" "$value") # Round to the desired precision
    done

    # Print the selectable values separated by spaces
    echo "${selectable_values[*]}"
}

generate_selectable_values() {
    local min="$1"
    local max="$2"
    local inc="$3"
    local precision="$INC_DECIMALS"

    # Initialize an empty array for selectable values
    local selectable_values=()

    # Initialize loop variable as floating-point number
    local value="$min"

    # Loop until the value exceeds the max
    while (( $(echo "$value <= $max" | bc -l) )); do
        # Check if the value starts with "."
        if [[ "${value:0:1}" == "." ]]; then
            # If it starts with ".", prepend "0" before the value
            value="0$value"
        fi
        
        # Append the value to the array
        selectable_values+=("$value")

        # Apply precision formatting for decimal increments
        if [[ "$inc" =~ \. ]]; then
            value=$(printf "%.${precision}f" "$value")
        fi
        
        # Increment the value using bc for floating-point arithmetic
        value=$(echo "$value + $inc" | bc -l)
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
            #echo "$input"
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

is_integer() {
    local value="$1"
    if [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "1"  # Return "1" for integer
    else
        echo "0"  # Return "0" for non-integer
    fi
}

#to be deleted
#rm $MY_PROJECT_PATH/configs/config_parameters
#rm $MY_PROJECT_PATH/configs/kernel*

echo ""
echo "${bold}config_add${normal}"
echo ""

#get config_id
config_id=$(get_config_id $MY_PROJECT_PATH)

#we avoid config_000 is created when configs is empty
if [[ "$config_id" == "config_000" ]]; then
    config_id="config_001"
fi

#create device_config.hpp (it is created each time so we can capture new MAX parameters)
if [ -f "$MY_PROJECT_PATH/configs/device_config.hpp" ]; then
    rm "$MY_PROJECT_PATH/configs/device_config.hpp"
fi
touch $MY_PROJECT_PATH/configs/device_config.hpp

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
done < "$MY_PROJECT_PATH/config_parameters"

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
    selectable_values_prompt=""
    case "$ranges_i" in
        *:*)
            colon_count=$(grep -o ":" <<< "$ranges_i" | wc -l)
            if [[ $colon_count -eq 1 ]]; then
                
                #extract min and max from ranges_i
                IFS=':' read -r min max <<< "$ranges_i"

                #replace already declared
                min=$(find_existing_parameter $min)
                max=$(find_existing_parameter $max)

                #check on integer
                is_integer_min=$(is_integer "$min")
                is_integer_max=$(is_integer "$max")

                # Derive increment
                if [[ "$is_integer_min" == "1" && "$is_integer_max" == "1" ]]; then
                    #min and max are integers
                    inc="1"
                elif [[ "$is_integer_min" == "0" && "$is_integer_max" == "0" ]]; then
                    #min and max are decimals
                    inc=$(echo "scale=$INC_DECIMALS; ($max - $min) / $INC_STEPS" | bc)                
                fi

            elif [[ $colon_count -eq 2 ]]; then
                
                #extract min, inc and max from ranges_i
                min="${ranges_i%%:*}"
                remaining="${ranges_i#*:}"
                inc="${remaining%%:*}"
                max="${remaining#*:}"

                #replace already declared
                min=$(find_existing_parameter $min)
                inc=$(find_existing_parameter $inc)
                max=$(find_existing_parameter $max)

            fi

            #generate selectable values
            selectable_values=$(generate_selectable_values "$min" "$max" "$inc")

            #get prompt
            num_elements=$(echo "$selectable_values" | wc -w)

            #check if the number of elements is more than 10
            if (( num_elements > $MAX_PROMPT_ELEMENTS )); then
                #more elements than expected
                if [[ "$inc" == "1" ]]; then
                    selectable_values_prompt="$min .. $max"
                else
                    selectable_values_prompt="$min:$inc:$max"
                fi
            else
                #less elements than expected
                selectable_values_prompt=$selectable_values
            fi    
            
            ;;
        *","*)
            #ranges_i is a comma separated list
            selectable_values=$(echo "$ranges_i" | tr "," " ")
            selectable_values_prompt=$selectable_values
            ;;
        *)
            #ranges_i is a constant (a string without any colon (:), comma (,), or any other specified character)
            selected_value=$ranges_i
            ;;
    esac

    #get value from the user
    if ! [[ "$selectable_values_prompt" == "" ]]; then
        #prompt the user to choose one of the selectable values
        read -rp "$parameter_i [$selectable_values_prompt]: " selected_value
        
        #validate user input
        while ! validate_input "$selected_value" "$selectable_values"; do
            read -rp "$parameter_i [$selectable_values_prompt]: " selected_value
        done
    fi

    #add parameter_i/selected_value to device_config.hpp or config_id
    if [[ "$parameter_i" == *_MAX* ]]; then
        #it contains the suffix _MAX (assumed as a xclbin parameter)
        add_to_config_file "device_config.hpp" "const int $parameter_i" "$selected_value"
    else
        #assumed as a host parameter
        add_to_config_file "$config_id" "$parameter_i" "$selected_value"
    fi

    #save already declared
    parameters_aux+=("$parameter_i = $selected_value")

done

echo ""
echo "The configuration ${bold}$config_id has been created!${normal}"
echo ""

#remove config_000 if exists
if [ -f "$MY_PROJECT_PATH/configs/config_000" ]; then
    rm "$MY_PROJECT_PATH/configs/config_000"
fi