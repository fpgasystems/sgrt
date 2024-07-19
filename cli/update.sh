#!/bin/bash

CLI_PATH="$(dirname "$0")"
CLI_NAME="sgrt"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
BASE_PATH=$(dirname "$CLI_PATH")
MAIN_BRANCH_URL="https://api.github.com/repos/fpgasystems/sgrt/commits/main"

#get last commit date on the remote
remote_commit_date=$(curl -s $MAIN_BRANCH_URL | jq -r '.commit.committer.date')

#get installed commit date
local_commit_date=$(cat $BASE_PATH/COMMIT_DATE)

#convert the dates to Unix timestamps
remote_timestamp=$(date -d "$remote_commit_date" +%s)
local_timestamp=$(date -d "$local_commit_date" +%s)

#compare the timestamps
update="0"
if [ "$local_timestamp" -lt "$remote_timestamp" ]; then
    echo ""
    echo "${bold}This will update $CLI_NAME to its latest version. Would you like to continue (y/n)?${normal}"
    update=$($CLI_PATH/common/push_dialog)
    echo ""
fi

echo "$remote_commit_date"
echo "$local_commit_date"
echo "$update"