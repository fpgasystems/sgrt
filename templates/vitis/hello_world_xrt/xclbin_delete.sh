#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
TEMPLATE="vadd"

cd $MY_PROJECT_PATH/src/xclbin
xclbins=( *".cpp" )

# Remove file extension from each element in the array
for ((i=0; i<${#xclbins[@]}; i++)); do
    xclbins[i]=${xclbins[i]%.cpp}
done

#there are not XCLBINs
if [ ${#xclbins[@]} -eq 0 ]; then
    exit
fi

echo ""
echo "${bold}xclbin_delete${normal}"
echo ""
echo "${bold}Please, choose the XCLBIN you want to delete:${normal}"
echo ""


#delete TEMPLATE from projects =====================> to complete!
#j=0
#for i in "${projects[@]}"
#do
#    if [[ $i =~ "common/" ]]; then
#        echo "" >&/dev/null
#    else
#        aux[j]=$i
#        j=$(($j + 1))
#    fi
#done

# Check if there is only one directory
#if [ ${#xclbins[@]} -eq 1 ]; then
#    #project_found="1"
#    #project_name=${aux[0]}
#    #project_name=${project_name::-1} # remove the last character, i.e. "/"
#
#    echo "Only one!"
#
#else
    #multiple_projects="1"
    PS3=""
    select xclbin in "${xclbins[@]}"; do
        if [[ -z $xclbin ]]; then
            echo "" >&/dev/null
        else
            #project_found="1"
            #project_name=${project_name::-1} # remove the last character, i.e. "/"
            break
        fi
    done
#fi

echo ""
echo "${bold}You are about to delete $xclbin. Do you want to continue (y/n)?${normal}"
while true; do
    read -p "" yn
    case $yn in
        "y") 
            rm $xclbin.cpp
            echo ""
            echo "The XCLBIN ${bold}$xclbin${normal} has been removed!"
            echo ""
            break
            ;;
        "n") 
            break
            ;;
    esac
done