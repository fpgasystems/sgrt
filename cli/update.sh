#!/bin/bash

CLI_PATH="$(dirname "$0")"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
BASE_PATH=$(dirname "$CLI_PATH")
MAIN_BRANCH_URL="https://api.github.com/repos/fpgasystems/sgrt/commits/main"


#only for sudo =====> at sgutil level

#get last commit date on the remote
remote_commit_date=$(curl -s $MAIN_BRANCH_URL | jq -r '.commit.committer.date')

#get installed commit date
local_commit_date=$(cat $BASE_PATH/COMMIT_DATE)

#convert the dates to Unix timestamps
remote_timestamp=$(date -d "$remote_commit_date" +%s)
local_timestamp=$(date -d "$local_commit_date" +%s)

#compare the timestamps
update_required="0"
if [ "$local_timestamp" -lt "$remote_timestamp" ]; then
    echo "The local commit date is anterior to the remote commit date."
    update_required="1"
fi

echo "$remote_commit_date"
echo "$local_commit_date"
echo "$update_required"