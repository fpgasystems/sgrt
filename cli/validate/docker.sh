#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check for docker_developers (containerroot)
member=$($CLI_PATH/common/is_member $USER containerroot)
if [ "$member" = "false" ]; then
    echo ""
    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
    echo ""
    exit
fi

#run docker hello world
docker run hello-world