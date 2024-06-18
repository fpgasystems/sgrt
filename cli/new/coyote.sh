#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="coyote"
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT) #COYOTE_COMMIT="4629886"
COYOTE_REPO="https://github.com/fpgasystems/Coyote.git"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on virtualized servers
virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)
if [ "$virtualized" = "1" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit
fi

#check on valid Vivado version
#if [ -z "$(echo $XILINX_VIVADO)" ]; then
#    echo ""
#    echo "Please, source a valid Vivado version for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check for vivado_developers
member=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$member" = "false" ]; then
    echo ""
    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
    echo ""
    exit
fi

#echo ""
#echo "${bold}sgutil new coyote${normal}"

#create my_projects directory
DIR="$MY_PROJECTS_PATH"
if ! [ -d "$DIR" ]; then
    mkdir ${DIR}
fi

#create coyote directory
DIR="$MY_PROJECTS_PATH/$WORKFLOW"
if ! [ -d "$DIR" ]; then
    mkdir ${DIR}
fi

# create commits file
#if [ ! -e "$DIR/commits" ]; then
#  #touch "$DIR/commits"
#  cp $CLI_PATH/constants/COYOTE_COMMIT $DIR/commits
#fi

#capture gh auth status
logged_in=$($CLI_PATH/common/gh_auth_status)

#inputs
read -a flags <<< "$@"

#check on flags
commit_found=""
commit_name=""
new_found=""
new_name=""
push_found=""
push_option=""
if [ "$flags" = "" ]; then
    #commit dialog
    commit_found="1"
    commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
    #header (1/2)
    echo "${bold}sgutil new $WORKFLOW (commit ID: $commit_name)${normal}"
    echo ""
    #new_dialog
    echo "${bold}Please, insert a non-existing name for your project:${normal}"
    echo ""
    result=$($CLI_PATH/common/new_dialog $MY_PROJECTS_PATH $WORKFLOW $commit_name_shell)
    new_found=$(echo "$result" | sed -n '1p')
    new_name=$(echo "$result" | sed -n '2p')
    echo ""
    #push_dialog
    push_option="0"
    if [ "$logged_in" = "1" ]; then
        echo "${bold}Would you like to add the repository to your GitHub account (y/n)?${normal}"
        push_option=$($CLI_PATH/common/push_dialog)
        echo ""
    fi
else
    #commit_dialog_check
    result="$("$CLI_PATH/common/commit_dialog_check" "${flags[@]}")"
    commit_found=$(echo "$result" | sed -n '1p')
    commit_name=$(echo "$result" | sed -n '2p')
    #check if commit exists
    exists=$(gh api repos/fpgasystems/Coyote/commits/$commit_name 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
    #forbidden combinations
    if [ "$commit_found" = "0" ]; then 
        commit_found="1"
        commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
    elif [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
        $CLI_PATH/help/new_coyote $COYOTE_COMMIT
        exit
    elif [ "$commit_found" = "1" ] && [ "$exists" = "0" ]; then 
        echo "Sorry, the commit ID ${bold}$commit_name${normal} does not exist on the repository."
        echo ""
        exit
    fi
    #new_dialog_check
    result="$("$CLI_PATH/common/new_dialog_check" "${flags[@]}")"
    new_found=$(echo "$result" | sed -n '1p')
    new_name=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [ "$new_found" = "1" ] && ([ "$new_name" = "" ] || [ -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name_shell/$new_name" ]); then 
        $CLI_PATH/help/new_coyote $COYOTE_COMMIT
        exit
    fi
    #push_dialog_check
    result="$("$CLI_PATH/common/push_dialog_check" "${flags[@]}")"
    push_found=$(echo "$result" | sed -n '1p')
    push_option=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [[ "$push_found" = "1" && "$push_option" != "0" && "$push_option" != "1" ]]; then 
        $CLI_PATH/help/new_coyote $COYOTE_COMMIT
        exit
    fi
    #header (2/2)
    echo "${bold}sgutil new $WORKFLOW (commit ID: $commit_name)${normal}"
    echo ""
    #new_found (forgotten mandatory 1)
    if [[ $new_found = "0" ]]; then
        echo "${bold}Please, insert a non-existing name for your project:${normal}"
        result=$($CLI_PATH/common/new_dialog $MY_PROJECTS_PATH $WORKFLOW $commit_name_shell)
        new_found=$(echo "$result" | sed -n '1p')
        new_name=$(echo "$result" | sed -n '2p')
        echo ""
    fi
    #push_dialog  (forgotten mandatory 1)
    if [[ $push_found = "0" ]]; then
        push_option="0"
        if [ "$logged_in" = "1" ]; then
            echo "${bold}Would you like to add the repository to your GitHub account (y/n)?${normal}"
            push_option=$($CLI_PATH/common/push_dialog)
            echo ""
        fi
    fi
fi

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$new_name"

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW/$commit_name

#create repository
if [ "$push_option" = "1" ]; then 
    gh repo create $new_name --public --clone
    echo ""
else
    mkdir -p $DIR
fi

#clone repository
$CLI_PATH/common/git_clone_coyote $DIR $commit_name

#change to project directory
cd $DIR

#save commit_name
echo "$commit_name" > COYOTE_COMMIT

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