#!/bin/bash

#inputs
GITHUB_CLI_PATH=$1
GITHUB_REPO=$2
COMMIT_ID=$3

#constants
COMMIT_ID_LENGTH=7

#check on COMMIT_ID string length
if [ ${#COMMIT_ID} -lt $COMMIT_ID_LENGTH ]; then
    echo ""
    echo "Your commit ID must have at least seven characters."
    echo ""
    exit 1
fi

exists=$($GITHUB_CLI_PATH/gh api repos/$GITHUB_REPO/commits/$COMMIT_ID 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')

echo "$exists"