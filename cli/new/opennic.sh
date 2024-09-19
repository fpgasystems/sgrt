#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
SGRT_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil new opennic --commit $comit_name_shell $comit_name_driver --project   $new_name --push $push_option
#example: /opt/sgrt/cli/sgutil new opennic --commit           807775             1cf2578 --project hello_world --push            0

check_connectivity() {
    local interface="$1"
    local remote_server="$2"

    # Ping the remote server using the specified interface, sending only 1 packet
    if ping -I "$interface" -c 1 "$remote_server" &> /dev/null; then
        echo "1"
    else
        echo "0"
    fi
}

#inputs
commit_name_shell=$2
commit_name_driver=$3
new_name=$5
push_option=$7

#constants
CPU_SERVERS_LIST="$CLI_PATH/constants/CPU_SERVERS_LIST"
FPGA_SERVERS_LIST="$CLI_PATH/constants/FPGA_SERVERS_LIST"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="opennic"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name_shell/$new_name"

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW/$commit_name_shell

#create repository
if [ "$push_option" = "1" ]; then 
    gh repo create $new_name --public --clone
    echo ""
else
    mkdir -p $DIR
fi

#clone repository
$CLI_PATH/common/git_clone_opennic $DIR $commit_name_shell $commit_name_driver

#change to project directory
#cd $DIR

#save commit_name_shell
echo "$commit_name_shell" > $DIR/ONIC_SHELL_COMMIT
echo "$commit_name_driver" > $DIR/ONIC_DRIVER_COMMIT

#add template files
#mkdir -p $DIR/src
cp $SGRT_PATH/templates/$WORKFLOW/config_add.sh $DIR/config_add
cp $SGRT_PATH/templates/$WORKFLOW/config_delete.sh $DIR/config_delete
cp $SGRT_PATH/templates/$WORKFLOW/config_parameters $DIR/config_parameters
cp $SGRT_PATH/templates/$WORKFLOW/Makefile $DIR/Makefile
cp -r $SGRT_PATH/templates/$WORKFLOW/configs $DIR
cp -r $SGRT_PATH/templates/$WORKFLOW/src $DIR

#compile files
chmod +x $DIR/config_add
chmod +x $DIR/config_delete

#get interface name
mellanox_name=$(nmcli dev | grep mellanox-0 | awk '{print $1}')

#read CPU and FPGA_SERVERS_LIST excluding the current hostname
IFS=$'\n' read -r -d '' -a remote_servers < <(cat "$CPU_SERVERS_LIST" "$FPGA_SERVERS_LIST" | grep -v "^$hostname$" && printf '\0')

#get target host
target_host=""
connected=""
for server in "${remote_servers[@]}"; do
    # Check connectivity to the current server
    if [[ "$(check_connectivity "$mellanox_name" "$server")" == "1" ]]; then
        target_host="$server"
        break
    fi
done

#update remote_server in config_parameters
sed -i "/^remote_server/s/xxxx-xxxxx-xx/$target_host/" "$DIR/config_parameters"

#push files
if [ "$push_option" = "1" ]; then 
    cd $DIR
    #update README.md 
    if [ -e README.md ]; then
        rm README.md
    fi
    echo "# "$new_name >> README.md
    #add gitignore
    echo ".DS_Store" >> .gitignore
    #add, commit, push
    git add .
    git commit -m "First commit"
    git push --set-upstream origin master
    echo ""
fi

#print message
echo "The project ${bold}$DIR${normal} has been created!"
echo ""

#author: https://github.com/jmoya82