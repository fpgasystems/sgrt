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
    configs=( "host_config_"* )
    #get the last configuration name
    last_config="${configs[-1]}"
    #extract the number part of the configuration name
    number_part="${last_config##*_}"  # This will extract the part after the last underscore
    number=$(printf "%03d" $((10#$number_part + 1)))  # Increment the number and format it as 3 digits with leading zeros
    #construct the new configuration name
    config_id="host_config_$number"
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

echo ""
echo "${bold}config_add${normal}"
echo ""

#get config_id
config_id=$(get_config_id $MY_PROJECT_PATH)

#we avoid host_config_000 is created when configs is empty
if [[ "$config_id" == "host_config_000" ]]; then
    config_id="host_config_001"
fi

#create device_config.hpp (it is created each time)
device_config_exists="0"
if [ -f "$MY_PROJECT_PATH/configs/device_config.hpp" ]; then
    rm -f "$MY_PROJECT_PATH/configs/device_config.hpp"
    device_config_exists="1"
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
output_file=""
for ((i = 0; i < ${#parameters[@]}; i++)); do
    
    #map to parameters
    parameter_i="${parameters[i]}"
    ranges_i="${ranges[i]}"

    #select output file (should appear in the correct order)
    if [[ "$parameter_i" == "device:" ]]; then
        output_file="device_config.hpp"
        echo "${bold}Device parameters:${normal}"
        echo ""
    elif [[ "$parameter_i" == "host:" ]]; then
        output_file="$config_id"
        echo ""
        echo "${bold}Host parameters:${normal}"
        echo ""
    else

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

        #add "const int" for device_config
        aux_str=""
        if [[ "$output_file" == "device_config.hpp" ]]; then
            aux_str="const int "
        fi

        #add parameter to config
        add_to_config_file "$output_file" "$aux_str$parameter_i" "$selected_value"

        #save already declared
        parameters_aux+=("$parameter_i = $selected_value")

    fi

done

#print message (tracks changes on device_config.hpp)
if [[ "$device_config_exists" == "0" ]]; then
    echo ""
    echo "The configurations ${bold}device_config.hpp${normal} and ${bold}$config_id have been created!${normal}"
    echo ""

    #copy device_config.hpp to project folder
    cp $MY_PROJECT_PATH/configs/device_config.hpp $MY_PROJECT_PATH/_device_config.hpp #$XCLBIN_BUILD_DIR/$xclbin_i.parameters

else

    #compare existing _device_config.hpp with just generated device_config.hpp
    are_equals=$($CLI_PATH/common/compare_files "$MY_PROJECT_PATH/configs/device_config.hpp" "$MY_PROJECT_PATH/_device_config.hpp")
    
    #print message
    if [[ "$are_equals" == "1" ]]; then
        echo ""
        echo "The configuration ${bold}$config_id has been created!${normal}"
        echo ""
    else
        echo ""
        echo "${bold}device_config.hpp${normal} has been updated; ${bold}$config_id has been created!${normal}"
        echo ""

        #update _device_config.hpp
        rm -f "$MY_PROJECT_PATH/_device_config.hpp"    
        cp $MY_PROJECT_PATH/configs/device_config.hpp $MY_PROJECT_PATH/_device_config.hpp #$XCLBIN_BUILD_DIR/$xclbin_i.parameters

    fi

fi

#remove host_config_000 if exists
if [ -f "$MY_PROJECT_PATH/configs/host_config_000" ]; then
    rm "$MY_PROJECT_PATH/configs/host_config_000"
fi

#change permissions (we avoid that user directly uses vi)
chmod a-w "$MY_PROJECT_PATH/configs/device_config.hpp"
chmod a-w "$MY_PROJECT_PATH/_device_config.hpp"
chmod a-w "$MY_PROJECT_PATH/configs/$config_id"