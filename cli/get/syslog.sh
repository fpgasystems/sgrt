#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#check for vivado_developers
member=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$member" = "0" ]; then
    echo ""
    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
    echo ""
    exit
fi

echo ""
echo "${bold}sgutil get syslog${normal}"
echo ""

eval "sudo /bin/cat /var/log/syslog"

echo ""