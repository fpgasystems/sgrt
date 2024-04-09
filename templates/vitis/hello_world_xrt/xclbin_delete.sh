#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"

#change to xclbin directory
#cd $MY_PROJECT_PATH/src/xclbin
#xclbins=( *".cpp" )

#change back to project directory
#cd $MY_PROJECT_PATH
#sw_emu=( *".sw_emu."* )
#hw_emu=( *".hw_emu."* )
#hw=( *".hw."* )

#read from sp
declare -a device_indexes
declare -a xclbin_names

while read -r line; do
    column_1=$(echo "$line" | awk '{print $1}')
    column_2=$(echo "$line" | awk '{print $2}')
    device_indexes+=("$column_1")
    xclbin_names+=("$column_2")
done < "$MY_PROJECT_PATH/sp"

#initialize arrays
files=()

#check for build directories
for ((i = 0; i < ${#device_indexes[@]}; i++)); do
    #map to sp
    device_index="${device_indexes[i]}"
    xclbin_name="${xclbin_names[i]}"

    #get platform
    platform_name_i=$($CLI_PATH/get/get_fpga_device_param $device_index platform)

    #check on .cpp
    if [ -f "$MY_PROJECT_PATH/src/xclbin/$xclbin_name.cpp" ]; then
        files+=( "$xclbin_name.cpp" )
    fi

    #check on sw_emu
    if [ -d "$MY_PROJECT_PATH/$xclbin_name.sw_emu.$platform_name_i" ]; then
        files+=( "$xclbin_name.sw_emu.$platform_name_i" )
    fi

    #check on sw_emu
    if [ -d "$MY_PROJECT_PATH/$xclbin_name.hw_emu.$platform_name_i" ]; then
        files+=( "$xclbin_name.hw_emu.$platform_name_i" )
    fi

    #check on hw
    if [ -d "$MY_PROJECT_PATH/$xclbin_name.hw.$platform_name_i" ]; then
        files+=( "$xclbin_name.hw.$platform_name_i" )
    fi
done

#there are not XCLBINs
if [ ${#files[@]} -eq 0 ]; then
    exit
fi

echo ""
echo "${bold}xclbin_delete${normal}"
echo ""
echo "${bold}Please, choose the the file you want to delete:${normal}"
echo ""

PS3=""
select file in "${files[@]}"; do
    if [[ -z $file ]]; then
        echo "" >&/dev/null
    else
        #project_found="1"
        #project_name=${project_name::-1} # remove the last character, i.e. "/"
        break
    fi
done

echo ""
echo "${bold}You are about to delete $file. Do you want to continue (y/n)?${normal}"
while true; do
    read -p "" yn
    case $yn in
        "y")
            #check on .cpp
            if [[ "$file" == *".cpp" ]]; then
                #deleting a .cpp also means delete all the builds
                file=${file%.cpp}
                
                #delete .cpp
                rm $MY_PROJECT_PATH/src/$file.cpp
                
                #delete builds    
                if [ -d "$MY_PROJECT_PATH/$file.sw_emu.$platform_name_i" ]; then
                    rm -rf $MY_PROJECT_PATH/$file.sw_emu.$platform_name_i
                fi

                if [ -d "$MY_PROJECT_PATH/$file.hw_emu.$platform_name_i" ]; then
                    rm -rf $MY_PROJECT_PATH/$file.hw_emu.$platform_name_i
                fi

                if [ -d "$MY_PROJECT_PATH/$file.hw.$platform_name_i" ]; then
                    rm -rf $MY_PROJECT_PATH/$file.hw.$platform_name_i
                fi
            elif [[ "$file" == *".sw_emu."* ]] || [[ "$file" == *".hw_emu."* ]] || [[ "$file" == *".hw."* ]]; then
                #we only delete builds
                rm -rf $MY_PROJECT_PATH/$file
            fi 
            
            echo ""
            echo "${bold}$file${normal} has been removed!"
            echo ""
            break
            ;;
        "n") 
            break
            ;;
    esac
done