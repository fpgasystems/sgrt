#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
MPICH_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MPICH_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="mpi"

#combine ACAP and FPGA lists removing duplicates
SERVER_LIST=$(sort -u $CLI_PATH/constants/ACAP_SERVERS_LIST $CLI_PATH/constants/FPGA_SERVERS_LIST)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get username
username=$USER

#get MPICH version
mpich_version=($(find "$MPICH_PATH" -mindepth 1 -maxdepth 1 -type d -name "*-install" -exec basename {} \;))

#check on valid MPICH version (only one should be installed)
if [ ! -d "$MPICH_PATH/$mpich_version" ]; then
    echo ""
    echo "Please, install a valid MPICH version for ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

#set environment
PATH=$MPICH_PATH/$mpich_version/bin:$PATH
LD_LIBRARY_PATH=$MPICH_PATH/$mpich_version/lib:$LD_LIBRARY_PATH

#inputs
flags=$@

#replace p by n
flags=${flags/p/n}

echo ""
echo "${bold}sgutil validate $WORKFLOW${normal}"

#create mpi directory (we do not know if sgutil new mpi has been run)
if ! [ -d "$MY_PROJECTS_PATH" ]; then
    mkdir ${MY_PROJECTS_PATH}
fi

DIR="$MY_PROJECTS_PATH/$WORKFLOW"
if ! [ -d "$DIR" ]; then
    mkdir ${DIR}
fi

#set default
if [ "$flags" = "" ]; then
    flags="-n 2"
    PROCESSES_PER_HOST=2
else

    read -a aux_flags <<< "$flags"
    read -a search_flags <<< "-n --processes"
    
    START=0
    for (( i=$START; i<${#aux_flags[@]}; i++ ))
    do
	    if [[ " ${search_flags[*]} " =~ " ${aux_flags[$i]} " ]]; then
	        i=$(($i+1))
	        PROCESSES_PER_HOST="${aux_flags[$i]} "
            break
	    fi
    done
fi

#define directories (1)
VALIDATION_DIR="$MY_PROJECTS_PATH/$WORKFLOW/validate_mpi"

#create temporal validation dir
if ! [ -d "$VALIDATION_DIR" ]; then
    mkdir ${VALIDATION_DIR}
    mkdir $VALIDATION_DIR/build_dir
fi

#get booked servers accessible with ssh
echo ""
echo "${bold}Quering remote servers with ssh:${normal}"
result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
servers_family_list_string=$(echo "$result" | sed -n '2p' | sed -n '1p')
num_remote_servers=$(echo "$servers_family_list" | wc -w)

#check on number of servers
if [ "$num_remote_servers" -eq 0 ]; then
    echo ""
    echo "Please, verify that you can ssh the targeted remote servers."
    echo ""
    exit
fi

echo ""
echo $servers_family_list_string

#convert string to an array
servers_family_list=($servers_family_list)

#setup keys
echo ""
$CLI_PATH/common/ssh_key_add $CLI_PATH "${servers_family_list[@]}"

#copy template from SGRT_PATH
SGRT_PATH=$(dirname "$CLI_PATH")
cp -rf $SGRT_PATH/templates/$WORKFLOW/hello_world/* $VALIDATION_DIR

#create config
cp $VALIDATION_DIR/configs/config_000.hpp $VALIDATION_DIR/configs/config_001.hpp

#build (compile)
$CLI_PATH/build/$WORKFLOW -p validate_mpi

# create hosts file
echo "${bold}Creating hosts file:${normal}"
echo ""
sleep 1

rm $VALIDATION_DIR/hosts

cd $VALIDATION_DIR
touch hosts
j=0
for i in "${servers_family_list[@]}"; do
    if [ "$i" != "$hostname" ]; then
        echo "$i-mellanox-0:$PROCESSES_PER_HOST" >> hosts
        ((j=j+1))
    fi
done
cat hosts
echo ""

#get interface name
mellanox_name=$(nmcli dev | grep mellanox-0 | awk '{print $1}')

#run
n=$(($j*$PROCESSES_PER_HOST))
echo "${bold}Running MPI:${normal}"
echo ""
echo "mpirun -n $n -f $VALIDATION_DIR/hosts -iface $mellanox_name $VALIDATION_DIR/build_dir/main"
echo ""
mpirun -n $n -f $VALIDATION_DIR/hosts -iface $mellanox_name $VALIDATION_DIR/build_dir/main

#remove temporal validation files
rm -rf $VALIDATION_DIR

echo ""