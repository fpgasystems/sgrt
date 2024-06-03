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

#inputs
read -a flags <<< "$@"

#check on flags
commit_found=""
commit_name=""
if [ "$flags" = "" ]; then
    #commit dialog
    commit_found="1"
    commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
    #header (1/2)
    echo ""
    echo "${bold}sgutil new $WORKFLOW (commit ID: $commit_name)${normal}"
    echo ""
    #project_dialog
    #echo ""
    #echo "${bold}Please, choose your $WORKFLOW commit:${normal}"
    #echo ""    
    #commit_found="1"
    #commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
    #echo $commit_name
    #echo ""
else
    #commit_dialog_check
    result="$("$CLI_PATH/common/commit_dialog_check" "${flags[@]}")"
    commit_found=$(echo "$result" | sed -n '1p')
    commit_name=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
        $CLI_PATH/sgutil new $WORKFLOW -h
        exit
    fi
    #check if commit exists
    exists=$(gh api repos/fpgasystems/Coyote/commits/$commit_name 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
    #forbidden combinations
    if [ "$commit_found" = "0" ]; then 
        commit_found="1"
        commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
    elif [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
        $CLI_PATH/sgutil new $WORKFLOW -h
        exit
    elif [ "$commit_found" = "1" ] && [ "$exists" = "0" ]; then 
        echo ""
        echo "Sorry, the commit ID ${bold}$commit_name${normal} does not exist on the repository."
        echo ""
        exit
    fi
    #header (2/2)
    echo ""
    echo "${bold}sgutil new $WORKFLOW (commit ID: $commit_name)${normal}"
    echo ""
fi

#create commit directory
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name"
if ! [ -d "$DIR" ]; then
    mkdir ${DIR}
fi

# create project
#echo ""
echo "${bold}Please, insert a non-existing name for your Coyote project:${normal}"
echo ""
while true; do
    read -p "" project_name
    #project_name cannot start with validate_
    if  [[ $project_name == validate_* ]]; then
        project_name=""
    fi
    DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"
    if ! [ -d "$DIR" ]; then
        break
    fi
done

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW

#add to GitHub if gh is installed
commit="0"
if [[ $(which gh) ]]; then
    echo ""
    echo "${bold}Would you like to add the repository to your GitHub account (y/n)?${normal}"
    while true; do
        read -p "" yn
        case $yn in
            "y") 
                echo ""
                #create GitHub repository and clone directory
                gh repo create $project_name --public --clone
                commit="1"
                break
                ;;
            "n") 
                #create plain directory
                mkdir $DIR
                break
                ;;
        esac
    done
    echo ""
fi

#catch gh repo create error (DIR has not been created)
if ! [ -d "$DIR" ]; then
    echo "Please, start GitHub CLI first using sgutil set gh"
    echo ""
    exit
fi

# clone repository
#echo ""
#echo "${bold}Checking out Coyote:${normal}"
#echo ""
#cd ${DIR}
#git clone https://github.com/fpgasystems/Coyote.git
#mv Coyote/* .
#rm -rf Coyote

#clone Coyote
$CLI_PATH/common/git_clone_coyote $DIR $commit_name

#change to project directory
cd $DIR

#save commit_name
echo "$commit_name" > COYOTE_COMMIT

#copy template from SGRT_PATH ------------- 2024.05.07: I need to see what we do with this
#SGRT_PATH=$(dirname "$CLI_PATH")
#cp -rf $SGRT_PATH/templates/$WORKFLOW/hello_world/* $DIR
#replace Makefile (main.cpp specific version)
#rm $DIR/sw/CMakeLists.txt
#mv $DIR/CMakeLists.txt $DIR/sw
#compile create config
#cd $DIR/src
#g++ -std=c++17 create_config.cpp -o ../create_config >&/dev/null

#commit files
if [ "$commit" = "1" ]; then 
    cd $DIR
    #update README.md 
    if [ -e README.md ]; then
        rm README.md
    fi
    echo "# "$project_name >> README.md
    #add gitignore
    echo ".DS_Store" >> .gitignore
    #add, commit, push
    git add .
    git commit -m "First commit"
    git push --set-upstream origin master
    #echo ""
fi

echo ""
echo "The project ${bold}$DIR${normal} has been created!"
echo ""