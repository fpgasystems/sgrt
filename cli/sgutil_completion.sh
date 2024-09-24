#!/bin/bash

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on server
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
is_virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)

#check on groups
is_sudo=$($CLI_PATH/common/is_sudo $USER)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)

command_completion_5() {
    CURRENT_WORD=$1
    COMP_CWORD=$2
    COMP_WORDS_1=$3
    COMP_WORDS_2=$4

    # Define an array for the remaining arguments
    shift 4
    args=("$@")

    # Access elements of the array (we could extend this)
    COMP_CWORD_2_1=${args[0]} #--device
    COMP_CWORD_2_2=${args[1]} #--project
    COMP_CWORD_2_3=${args[2]} 
    COMP_CWORD_2_4=${args[3]} 

    if [[ "${COMP_WORDS[1]}" == "$COMP_WORDS_1" && "${COMP_WORDS[2]}" == "$COMP_WORDS_2" ]]; then
        if [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_1" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_1:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_2 $COMP_CWORD_2_3 $COMP_CWORD_2_4" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_2" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_2:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1 $COMP_CWORD_2_3 $COMP_CWORD_2_4" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_3" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_3:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1 $COMP_CWORD_2_2 $COMP_CWORD_2_4" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_4" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_4:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1 $COMP_CWORD_2_2 $COMP_CWORD_2_3" -- ${CURRENT_WORD}))
        fi
    fi
}

command_completion_7() {
    CURRENT_WORD=$1
    COMP_CWORD=$2
    COMP_WORDS_1=$3
    COMP_WORDS_2=$4
    COMP_WORDS_3=$5

    # Define an array for the remaining arguments
    shift 5
    args=("$@")

    # Access elements of the array (we could extend this)
    COMP_CWORD_2_1=${args[0]}
    COMP_CWORD_2_2=${args[1]}
    COMP_CWORD_2_3=${args[2]}

    if [[ "${COMP_WORDS[1]}" == "$COMP_WORDS_1" && "${COMP_WORDS[2]}" == "$COMP_WORDS_2" && ( "${COMP_WORDS[3]}" == "$COMP_WORDS_3" || "${COMP_WORDS[3]}" == "-${COMP_WORDS_3:2:1}" ) ]]; then
        if [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_1" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_1:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_2 $COMP_CWORD_2_3" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_2" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_2:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1 $COMP_CWORD_2_3" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_3" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_3:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1 $COMP_CWORD_2_2" -- ${CURRENT_WORD}))
        fi
    fi
}

command_completion_9() {
    CURRENT_WORD=$1
    COMP_CWORD=$2
    COMP_WORDS_1=$3
    COMP_WORDS_2=$4
    COMP_WORDS_3=$5
    COMP_WORDS_5=$6 

    # Define an array for the remaining arguments
    shift 6
    args=("$@")

    # Access elements of the array (we could extend this)
    COMP_CWORD_2_1=${args[0]}
    COMP_CWORD_2_2=${args[1]}
    COMP_CWORD_2_3=${args[2]}

    if [[ "${COMP_WORDS[1]}" == "$COMP_WORDS_1" && "${COMP_WORDS[2]}" == "$COMP_WORDS_2" && ( "${COMP_WORDS[3]}" == "$COMP_WORDS_3" || "${COMP_WORDS[3]}" == "-${COMP_WORDS_3:2:1}" ) && ( "${COMP_WORDS[5]}" == "$COMP_WORDS_5" || "${COMP_WORDS[5]}" == "-${COMP_WORDS_5:2:1}" ) ]]; then
        if [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_1" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_1:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_2" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_2" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_2:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1" -- ${CURRENT_WORD}))
        fi
    fi
}

_sgutil_completions()
{
    local cur

    cur=${COMP_WORDS[COMP_CWORD]}

    # Check if the current word is a file path
    if [[ ${cur} == ./* || ${cur} == /* || ${cur} == ../* ]]; then
        # Trim trailing spaces and slash if present
        cur="${cur%%[[:space:]]}"

        # Generate completions for directories and files
        dir_completions=($(compgen -d -- "${cur}"))
        file_completions=($(compgen -f -- "${cur}"))

        # Combine both directory and file completions
        COMPREPLY=("${dir_completions[@]}" "${file_completions[@]}")

        # Add a trailing slash for directory completions
        for ((i = 0; i < ${#COMPREPLY[@]}; i++)); do
            if [[ -d ${COMPREPLY[$i]} ]]; then
                COMPREPLY[$i]+="/"
            fi
        done

        # Disable appending space after completion
        compopt -o nospace
        return 0
    fi

    #evaluate integrations
    gpu_integrations=$($CLI_PATH/common/enable_integrations "gpu" $is_acap $is_build $is_fpga $is_vivado_developer)
    vivado_integrations=$($CLI_PATH/common/enable_integrations "vivado" $is_acap $is_build $is_fpga $is_vivado_developer)

    case ${COMP_CWORD} in
        1)
            #check on server
            commands="examine get set --help --release"
            if [ "$is_acap" = "1" ]; then
                commands="${commands} build"
            fi
            if [ "$is_build" = "1" ]; then
                commands="${commands} build enable examine new"
            fi
            if [ "$is_fpga" = "1" ]; then
                commands="${commands} build"
            fi
            if [ "$is_gpu" = "1" ]; then
                commands="${commands} build"
            fi
            if [ "$gpu_integrations" = "1" ]; then
                commands="${commands} build new run validate"
            fi
            if [ "$vivado_integrations" = "1" ]; then
                commands="${commands} build new"
            fi
            if [ ! "$is_build" = "1" ] && [ "$vivado_integrations" = "1" ]; then
                commands="${commands} program run validate"
            fi

            # Check on groups
            if [ "$is_sudo" = "1" ]; then
                commands="${commands} reboot update"
            fi
            if [ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]; then
                commands="${commands} reboot"
            fi

            commands_array=($commands)
            commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
            commands_string=$(echo "${commands_array[@]}")
            COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
            ;;
        2)
            case ${COMP_WORDS[COMP_CWORD-1]} in
                build)
                    commands="c --help"
                    #if [ "$is_acap" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
                    #    commands="${commands} opennic"
                    #fi
                    #if [ "$is_build" = "1" ]; then
                    #    commands="${commands} hip"
                    #    if [ "$is_vivado_developer" = "1" ]; then
                    #        commands="${commands} opennic"
                    #    fi
                    #fi
                    #if [ "$is_fpga" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
                    #    commands="${commands} opennic"
                    #fi
                    #if [ "$is_gpu" = "1" ]; then
                    #    commands="${commands} hip"
                    #fi
                    if [ "$gpu_integrations" = "1" ]; then
                        commands="${commands} hip"
                    fi
                    if [ "$vivado_integrations" = "1" ]; then
                        commands="${commands} opennic"
                    fi
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
                enable)
                    COMPREPLY=($(compgen -W "vitis vivado xrt --help" -- ${cur}))
                    ;;
                examine)
                    COMPREPLY=($(compgen -W "--help" -- ${cur}))
                    ;;
                get)
                    commands="ifconfig servers topo --help"
                    if [ "$is_acap" = "1" ]; then
                        commands="${commands} bdf clock name memory network platform resource serial slr workflow"
                    fi
                    if [ "$is_build" = "1" ]; then
                        commands="${commands} ifconfig servers"
                    fi
                    if [ "$is_fpga" = "1" ]; then
                        commands="${commands} bdf clock name memory network platform resource serial slr workflow"
                    fi
                    if [ "$is_gpu" = "1" ]; then
                        commands="${commands} bus"
                    fi 
                    if [ "$is_vivado_developer" = "1" ]; then
                        commands="${commands} syslog"
                    fi 
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    #COMPREPLY=($(compgen -W "bdf clock bus name ifconfig memory network platform resource serial slr servers syslog workflow --help" -- ${cur}))
                    ;;
                new)
                    commands="--help"
                    #if [ "$is_acap" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
                    #    commands="${commands} opennic"
                    #fi
                    #if [ "$is_build" = "1" ]; then
                    #    commands="${commands} hip"
                    #    if [ "$is_vivado_developer" = "1" ]; then
                    #        commands="${commands} opennic"
                    #    fi
                    #fi
                    #if [ "$is_fpga" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
                    #    commands="${commands} opennic"
                    #fi
                    #if [ "$is_gpu" = "1" ]; then
                    #    commands="${commands} hip"
                    #fi
                    if [ "$gpu_integrations" = "1" ]; then
                        commands="${commands} hip"
                    fi
                    if [ "$vivado_integrations" = "1" ]; then
                        commands="${commands} opennic"
                    fi
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    #COMPREPLY=($(compgen -W "hip opennic --help" -- ${cur}))
                    ;;
                program)
                    COMPREPLY=($(compgen -W "driver opennic reset revert vivado --help" -- ${cur}))
                    ;;
                reboot)
                    COMPREPLY=($(compgen -W "--help" -- ${cur}))
                    ;;
                run)
                    COMPREPLY=($(compgen -W "hip opennic --help" -- ${cur}))
                    ;;
                set)
                    COMPREPLY=($(compgen -W "gh keys license mtu --help" -- ${cur})) #write
                    ;;
                update)
                    COMPREPLY=($(compgen -W "--help" -- ${cur}))
                    ;;
                validate)
                    COMPREPLY=($(compgen -W "docker hip opennic vitis --help" -- ${cur}))
                    ;;
            esac
            ;;
        3)
            case ${COMP_WORDS[COMP_CWORD-2]} in
                build)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        c)
                            COMPREPLY=($(compgen -W "--source --help" -- ${cur}))
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--project --help" -- ${cur}))
                            ;;
                        opennic)
                            if [ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]; then
                                #platform is not offered
                                COMPREPLY=($(compgen -W "--commit --project --help" -- ${cur}))
                            elif [ "$is_vivado_developer" = "1" ]; then
                                COMPREPLY=($(compgen -W "--commit --platform --project --help" -- ${cur}))
                            fi
                            ;;
                    esac
                    ;;
                enable) 
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        vitis)
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        vivado) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        xrt) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                    esac
                    ;;
                get)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        bdf)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        clock)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        bus)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        memory)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        name)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        ifconfig) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        network) 
                            COMPREPLY=($(compgen -W "--device --port --help" -- ${cur}))
                            ;;
                        platform) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        resource)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        serial) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        slr)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        servers) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        syslog) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        topo) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        workflow) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                    esac
                    ;;
                new) 
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        hip)
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "--commit --project --push --help" -- ${cur}))
                            ;;
                    esac
                    ;;
                program)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        driver)
                            COMPREPLY=($(compgen -W "--insert --params --remove --help" -- ${cur}))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "--commit --device --project --remote --help" -- ${cur}))
                            ;;
                        reset)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        revert)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        vivado) 
                            COMPREPLY=($(compgen -W "--bitstream --device --help" -- ${cur})) # --driver 
                            ;;
                    esac
                    ;;
                run)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        hip)
                            COMPREPLY=($(compgen -W "--device --project --help" -- ${cur}))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "--commit --config --device --project --help" -- ${cur})) 
                            ;;
                    esac
                    ;;
                set)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        gh)
                            COMPREPLY=($(compgen -W "--help" -- ${cur})) 
                            ;;
                        keys)
                            COMPREPLY=($(compgen -W "--help" -- ${cur})) 
                            ;;
                        license)
                            COMPREPLY=($(compgen -W "--help" -- ${cur})) 
                            ;;
                        mtu)
                            COMPREPLY=($(compgen -W "--help" -- ${cur})) 
                            ;;
                        #write)
                        #    COMPREPLY=($(compgen -W "--index --help" -- ${cur})) 
                        #    ;;
                    esac
                    ;;
                validate)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        docker)
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "--commit --device --fec --help" -- ${cur}))
                            ;;
                        vitis) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                    esac
                    ;;
            esac
            ;;
        5) 
            #COMP_WORDS[0]=sgutil
            #COMP_WORDS[1]=program
            #COMP_WORDS[2]=coyote
            #COMP_WORDS[3]=other_flags
            #COMP_WORDS[4]=value
            #Example: sgutil program coyote --device 1 -- (there are five words)

            #build
            if [ "$is_build" = "0" ]; then
                #platform is not offered
                other_flags=( "--commit" "--project" )
                command_completion_5 "$cur" "$COMP_CWORD" "build" "opennic" "${other_flags[@]}"
            else
                other_flags=( "--commit" "--platform" "--project" )
                command_completion_5 "$cur" "$COMP_CWORD" "build" "opennic" "${other_flags[@]}"
            fi

            #get
            other_flags=( "--device" "--port" )
            command_completion_5 "$cur" "$COMP_CWORD" "get" "network" "${other_flags[@]}"

            #new
            other_flags=( "--commit" "--project" "--push")
            command_completion_5 "$cur" "$COMP_CWORD" "new" "opennic" "${other_flags[@]}"

            #program
            other_flags=( "--insert" "--params " ) #--remove
            command_completion_5 "$cur" "$COMP_CWORD" "program" "driver" "${other_flags[@]}"

            other_flags=( "--commit" "--device" "--project" "--remote" )
            command_completion_5 "$cur" "$COMP_CWORD" "program" "opennic" "${other_flags[@]}"

            other_flags=( "--bitstream" "--device" )
            command_completion_5 "$cur" "$COMP_CWORD" "program" "vivado" "${other_flags[@]}"

            #run
            other_flags=( "--device" "--project" )
            command_completion_5 "$cur" "$COMP_CWORD" "run" "hip" "${other_flags[@]}"

            other_flags=( "--commit" "--config" "--device" "--project" )
            command_completion_5 "$cur" "$COMP_CWORD" "run" "opennic" "${other_flags[@]}"

            #validate
            other_flags=( "--commit" "--device" "--fec" )
            command_completion_5 "$cur" "$COMP_CWORD" "validate" "opennic" "${other_flags[@]}"
            ;;
        7)
            #COMP_WORDS[0]=sgutil
            #COMP_WORDS[1]=program
            #COMP_WORDS[2]=coyote
            #COMP_WORDS[3]=--device
            #COMP_WORDS[4]=1
            #COMP_WORDS[5]=--project / --remote
            #COMP_WORDS[6]=hello_world
            #Example: sgutil program coyote --device 1 --project hello_world -- (there are seven words)
            
            #build opennic
            other_flags=( "--platform" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "build" "opennic" "--commit" "${other_flags[@]}"

            #other_flags=( "--commit" "--platform" "--project" )
            #command_completion_7 "$cur" "$COMP_CWORD" "build" "opennic" "--config" "${other_flags[@]}"
            
            other_flags=( "--commit" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "build" "opennic" "--platform" "${other_flags[@]}"

            other_flags=( "--commit" "--platform" )
            command_completion_7 "$cur" "$COMP_CWORD" "build" "opennic" "--project" "${other_flags[@]}"
            
            #new opennic
            other_flags=( "--project" "--push" )
            command_completion_7 "$cur" "$COMP_CWORD" "new" "opennic" "--commit" "${other_flags[@]}"

            other_flags=( "--commit" "--push" )
            command_completion_7 "$cur" "$COMP_CWORD" "new" "opennic" "--project" "${other_flags[@]}"

            other_flags=( "--commit" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "new" "opennic" "--push" "${other_flags[@]}"
            
            #program driver
            #other_flags=( "--params" )
            #command_completion_7 "$cur" "$COMP_CWORD" "program" "driver" "--insert" "${other_flags[@]}"

            #other_flags=( "--insert" )
            #command_completion_7 "$cur" "$COMP_CWORD" "program" "driver" "--params" "${other_flags[@]}"

            other_flags=( "" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "driver" "--remove" "${other_flags[@]}"
            
            #program opennic
            other_flags=( "--device" "--project" "--remote" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "opennic" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--project" "--remote" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "opennic" "--device" "${other_flags[@]}"

            other_flags=( "--commit" "--device" "--remote" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "opennic" "--project" "${other_flags[@]}"

            other_flags=( "--commit" "--device" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "opennic" "--remote" "${other_flags[@]}"

            #run opennic
            other_flags=( "--config" "--device" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "run" "opennic" "--commit" "${other_flags[@]}"

            other_flags=( "--commit" "--device" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "run" "opennic" "--config" "${other_flags[@]}"

            other_flags=( "--commit" "--config" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "run" "opennic" "--device" "${other_flags[@]}"

            other_flags=( "--commit" "--config" "--device" )
            command_completion_7 "$cur" "$COMP_CWORD" "run" "opennic" "--project" "${other_flags[@]}"

            #validate opennic
            other_flags=( "--device" "--fec" )
            command_completion_7 "$cur" "$COMP_CWORD" "validate" "opennic" "--commit" "${other_flags[@]}"

            other_flags=( "--commit" "--fec" )
            command_completion_7 "$cur" "$COMP_CWORD" "validate" "opennic" "--device" "${other_flags[@]}"

            other_flags=( "--commit" "--device" )
            command_completion_7 "$cur" "$COMP_CWORD" "validate" "opennic" "--fec" "${other_flags[@]}"
            ;;
        9)

            #COMP_WORDS[0]=sgutil
            #COMP_WORDS[1]=program
            #COMP_WORDS[2]=coyote
            #COMP_WORDS[3]=--device
            #COMP_WORDS[4]=1
            #COMP_WORDS[5]=--project
            #COMP_WORDS[6]=hello_world
            #COMP_WORDS[7]=--commit / --remote
            #COMP_WORDS[8]=0
            #Example: sgutil program coyote --device 1 --project hello_world --commit 0 -- (there are nine words)

            #build opennic --commit
            #other_flags=( "--platform" "--project" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--commit" "--config" "${other_flags[@]}"
            
            #other_flags=( "--config" "--project" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--commit" "--platform" "${other_flags[@]}"

            #other_flags=( "--config" "--platform" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--commit" "--project" "${other_flags[@]}"
            
            #build opennic --config
            #other_flags=( "--platform" "--project" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--config" "--commit" "${other_flags[@]}"
            
            #other_flags=( "--commit" "--project" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--config" "--platform" "${other_flags[@]}"

            #other_flags=( "--commit" "--platform" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--config" "--project" "${other_flags[@]}"

            #build opennic --platform
            #other_flags=( "--config" "--project" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--platform" "--commit" "${other_flags[@]}"
            
            #other_flags=( "--commit" "--project" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--platform" "--config" "${other_flags[@]}"

            #other_flags=( "--commit" "--config" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--platform" "--project" "${other_flags[@]}"

            #build opennic --project
            #other_flags=( "--config" "--platform" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--project" "--commit" "${other_flags[@]}"
            
            #other_flags=( "--commit" "--platform" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--project" "--config" "${other_flags[@]}"

            #other_flags=( "--commit" "--config" )
            #command_completion_9 "$cur" "$COMP_CWORD" "build" "opennic" "--project" "--platform" "${other_flags[@]}"

            #program opennic --commit
            other_flags=( "--project" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--commit" "--device" "${other_flags[@]}"
            
            other_flags=( "--device" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--commit" "--project" "${other_flags[@]}"

            other_flags=( "--device" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--commit" "--remote" "${other_flags[@]}"
            
            #program opennic --device
            other_flags=( "--project" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--device" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--device" "--project" "${other_flags[@]}"

            other_flags=( "--commit" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--device" "--remote" "${other_flags[@]}"

            #program opennic --project
            other_flags=( "--device" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--project" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--project" "--device" "${other_flags[@]}"

            other_flags=( "--commit" "--device" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--project" "--remote" "${other_flags[@]}"

            #program opennic --remote
            other_flags=( "--device" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--remote" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--remote" "--device" "${other_flags[@]}"

            other_flags=( "--commit" "--device" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "opennic" "--remote" "--project" "${other_flags[@]}"

            #run opennic --commit
            other_flags=( "--device" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--commit" "--config" "${other_flags[@]}"
            
            other_flags=( "--config" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--commit" "--device" "${other_flags[@]}"

            other_flags=( "--config" "--device" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--commit" "--project" "${other_flags[@]}"
            
            #run opennic --config
            other_flags=( "--device" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--config" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--config" "--device" "${other_flags[@]}"

            other_flags=( "--commit" "--device" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--config" "--project" "${other_flags[@]}"

            #run opennic --device
            other_flags=( "--config" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--device" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--device" "--config" "${other_flags[@]}"

            other_flags=( "--commit" "--config" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--device" "--project" "${other_flags[@]}"

            #run opennic --project
            other_flags=( "--config" "--device" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--project" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--device" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--project" "--config" "${other_flags[@]}"

            other_flags=( "--commit" "--config" )
            command_completion_9 "$cur" "$COMP_CWORD" "run" "opennic" "--project" "--device" "${other_flags[@]}"
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _sgutil_completions sgutil