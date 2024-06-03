#!/bin/bash

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
        #cur="${cur%/}"
        # Generate completions for directories
        dir_completions=($(compgen -d -- ${cur}))
        # Generate completions for files
        file_completions=($(compgen -f -- ${cur}))
        # Check if there are directory completions
        if [[ ${#dir_completions[@]} -gt 0 ]]; then
            COMPREPLY=("${dir_completions[@]}")
        else
            COMPREPLY=("${file_completions[@]}")
        fi
        # If the completion is a directory, add a trailing slash
        for ((i = 0; i < ${#COMPREPLY[@]}; i++)); do
            if [[ -d ${COMPREPLY[$i]} ]]; then
                COMPREPLY[$i]+="/"
            fi
        done
        # Disable appending space after completion
        compopt -o nospace
        return 0
    fi

    case ${COMP_CWORD} in
        1)
            COMPREPLY=($(compgen -W "build enable examine get new program reboot run set validate --help --version" -- ${cur}))
            ;;
        2)
            case ${COMP_WORDS[COMP_CWORD-1]} in
                build)
                    COMPREPLY=($(compgen -W "coyote hip mpi vitis --help" -- ${cur}))
                    ;;
                enable)
                    COMPREPLY=($(compgen -W "vitis vivado xrt --help" -- ${cur}))
                    ;;
                examine)
                    COMPREPLY=($(compgen -W "--help" -- ${cur}))
                    ;;
                get)
                    COMPREPLY=($(compgen -W "bdf clock bus name ifconfig memory network platform resource serial slr servers syslog workflow --help" -- ${cur}))
                    ;;
                new)
                    COMPREPLY=($(compgen -W "coyote hip mpi opennic vitis --help" -- ${cur}))
                    ;;
                program)
                    COMPREPLY=($(compgen -W "coyote driver reset revert vitis vivado --help" -- ${cur}))
                    ;;
                reboot)
                    COMPREPLY=($(compgen -W "--help" -- ${cur}))
                    ;;
                run)
                    COMPREPLY=($(compgen -W "coyote hip mpi vitis --help" -- ${cur}))
                    ;;
                set)
                    COMPREPLY=($(compgen -W "gh keys license mtu --help" -- ${cur})) #write
                    ;;
                validate)
                    COMPREPLY=($(compgen -W "coyote docker hip iperf mpi vitis vitis-ai --help" -- ${cur}))
                    ;;
            esac
            ;;
        3)
            case ${COMP_WORDS[COMP_CWORD-2]} in
                build)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        coyote)
                            COMPREPLY=($(compgen -W "--commit --platform --project --help" -- ${cur}))
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--project --help" -- ${cur}))
                            ;;
                        mpi)
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        vitis) 
                            COMPREPLY=($(compgen -W "--project --target --help" -- ${cur})) #--xclbin 
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
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
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
                        workflow) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                    esac
                    ;;
                new) 
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        coyote)
                            COMPREPLY=($(compgen -W "--commit --help" -- ${cur}))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "--commit --help" -- ${cur}))
                            ;;
                    esac
                    ;;
                program)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        coyote)
                            COMPREPLY=($(compgen -W "--commit --device --project --remote --help" -- ${cur}))
                            ;;
                        driver)
                            COMPREPLY=($(compgen -W "--module --params --help" -- ${cur}))
                            ;;
                        reset)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        revert)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        vitis) 
                            COMPREPLY=($(compgen -W "--device --project --remote --xclbin --help" -- ${cur}))
                            ;;
                        vivado) 
                            COMPREPLY=($(compgen -W "--bitstream --device --help" -- ${cur})) # --driver 
                            ;;
                    esac
                    ;;
                run)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        coyote) # run 
                            COMPREPLY=($(compgen -W "--commit --device --project --help" -- ${cur})) 
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--device --project --help" -- ${cur}))
                            ;;
                        mpi)
                            COMPREPLY=($(compgen -W "--project --help" -- ${cur}))
                            ;;
                        vitis)
                            COMPREPLY=($(compgen -W "--config --project --target --help" -- ${cur})) #--device 
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
                        coyote)
                            COMPREPLY=($(compgen -W "--commit --device --help" -- ${cur}))
                            ;;
                        docker)
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        iperf)
                            COMPREPLY=($(compgen -W "--bandwidth --parallel --time --udp --help" -- ${cur}))
                            ;;
                        mpi) 
                            COMPREPLY=($(compgen -W "--processes --help" -- ${cur}))
                            ;;
                        vitis) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        vitis-ai) 
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
            other_flags=( "--commit" "--platform" "--project" )
            command_completion_5 "$cur" "$COMP_CWORD" "build" "coyote" "${other_flags[@]}"

            other_flags=( "--project" "--target" )
            command_completion_5 "$cur" "$COMP_CWORD" "build" "vitis" "${other_flags[@]}"

            #program
            other_flags=( "--commit" "--device" "--project" "--remote" )
            command_completion_5 "$cur" "$COMP_CWORD" "program" "coyote" "${other_flags[@]}"
            
            other_flags=( "--module" "--params" )
            command_completion_5 "$cur" "$COMP_CWORD" "program" "driver" "${other_flags[@]}"

            other_flags=( "--device" "--project" "--remote" "--xclbin" )
            command_completion_5 "$cur" "$COMP_CWORD" "program" "vitis" "${other_flags[@]}"

            other_flags=( "--bitstream" "--device" )
            command_completion_5 "$cur" "$COMP_CWORD" "program" "vivado" "${other_flags[@]}"

            #run
            other_flags=( "--commit" "--device" "--project" )
            command_completion_5 "$cur" "$COMP_CWORD" "run" "coyote" "${other_flags[@]}"

            other_flags=( "--device" "--project" )
            command_completion_5 "$cur" "$COMP_CWORD" "run" "hip" "${other_flags[@]}"

            other_flags=( "--config" "--project" "--target" )
            command_completion_5 "$cur" "$COMP_CWORD" "run" "vitis" "${other_flags[@]}"

            #validate
            other_flags=( "--commit" "--device" )
            command_completion_5 "$cur" "$COMP_CWORD" "validate" "coyote" "${other_flags[@]}"

            other_flags=( "--bandwidth" "--parallel" "--time" "--udp" )
            command_completion_5 "$cur" "$COMP_CWORD" "validate" "iperf" "${other_flags[@]}"
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
            
            #build coyote
            other_flags=( "--platform" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "build" "coyote" "--commit" "${other_flags[@]}"

            other_flags=( "--commit" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "build" "coyote" "--platform" "${other_flags[@]}"

            other_flags=( "--commit" "--platform" )
            command_completion_7 "$cur" "$COMP_CWORD" "build" "coyote" "--project" "${other_flags[@]}"
            
            #program coyote
            other_flags=( "--device" "--project" "--remote" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "coyote" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--project" "--remote" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "coyote" "--device" "${other_flags[@]}"

            other_flags=( "--commit" "--device" "--remote" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "coyote" "--project" "${other_flags[@]}"

            other_flags=( "--commit" "--device" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "coyote" "--remote" "${other_flags[@]}"

            #program vitis    
            other_flags=( "--project" "--remote" "--xclbin" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "vitis" "--device" "${other_flags[@]}"

            other_flags=( "--device" "--remote" "--xclbin" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "vitis" "--project" "${other_flags[@]}"

            other_flags=( "--device" "--project" "--xclbin" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "vitis" "--remote" "${other_flags[@]}"

            other_flags=( "--device" "--project" "--remote" )
            command_completion_7 "$cur" "$COMP_CWORD" "program" "vitis" "--xclbin" "${other_flags[@]}"

            #run coyote
            other_flags=( "--device" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "run" "coyote" "--commit" "${other_flags[@]}"

            other_flags=( "--commit" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "run" "coyote" "--device" "${other_flags[@]}"

            other_flags=( "--commit" "--device" )
            command_completion_7 "$cur" "$COMP_CWORD" "run" "coyote" "--project" "${other_flags[@]}"

            #run vitis    
            other_flags=( "--project" "--target" )
            command_completion_7 "$cur" "$COMP_CWORD" "run" "vitis" "--config" "${other_flags[@]}"

            other_flags=( "--config" "--target" )
            command_completion_7 "$cur" "$COMP_CWORD" "run" "vitis" "--project" "${other_flags[@]}"

            other_flags=( "--config" "--project" )
            command_completion_7 "$cur" "$COMP_CWORD" "run" "vitis" "--target" "${other_flags[@]}"

            #validate iperf
            other_flags=( "--parallel" "--time" "--udp" )
            command_completion_7 "$cur" "$COMP_CWORD" "validate" "iperf" "--bandwidth" "${other_flags[@]}"

            other_flags=( "--bandwidth" "--time" "--udp" )
            command_completion_7 "$cur" "$COMP_CWORD" "validate" "iperf" "--parallel" "${other_flags[@]}"

            other_flags=( "--bandwidth" "--parallel" "--udp" )
            command_completion_7 "$cur" "$COMP_CWORD" "validate" "iperf" "--time" "${other_flags[@]}"

            other_flags=( "--bandwidth" "--parallel" "--time" )
            command_completion_7 "$cur" "$COMP_CWORD" "validate" "iperf" "--udp" "${other_flags[@]}"
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

            #program coyote --commit
            other_flags=( "--project" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--commit" "--device" "${other_flags[@]}"
            
            other_flags=( "--device" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--commit" "--project" "${other_flags[@]}"

            other_flags=( "--device" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--commit" "--remote" "${other_flags[@]}"
            
            #program coyote --device
            other_flags=( "--project" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--device" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--device" "--project" "${other_flags[@]}"

            other_flags=( "--commit" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--device" "--remote" "${other_flags[@]}"

            #program coyote --project
            other_flags=( "--device" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--project" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--project" "--device" "${other_flags[@]}"

            other_flags=( "--commit" "--device" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--project" "--remote" "${other_flags[@]}"

            #program coyote --remote
            other_flags=( "--device" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--remote" "--commit" "${other_flags[@]}"
            
            other_flags=( "--commit" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--remote" "--device" "${other_flags[@]}"

            other_flags=( "--commit" "--device" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "coyote" "--remote" "--project" "${other_flags[@]}"

            #program vitis --device
            other_flags=( "--remote" "--xclbin" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--device" "--project" "${other_flags[@]}"

            other_flags=( "--project" "--xclbin" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--device" "--remote" "${other_flags[@]}"

            other_flags=( "--project" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--device" "--xclbin" "${other_flags[@]}"

            #program vitis --project
            other_flags=( "--remote" "--xclbin" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--project" "--device" "${other_flags[@]}"

            other_flags=( "--device" "--xclbin" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--project" "--remote" "${other_flags[@]}"

            other_flags=( "--device" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--project" "--xclbin" "${other_flags[@]}"

            #program vitis --remote
            other_flags=( "--project" "--xclbin" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--remote" "--device" "${other_flags[@]}"

            other_flags=( "--device" "--xclbin" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--remote" "--project" "${other_flags[@]}"

            other_flags=( "--device" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--remote" "--xclbin" "${other_flags[@]}"

            #program vitis --xclbin
            other_flags=( "--project" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--xclbin" "--device" "${other_flags[@]}"

            other_flags=( "--device" "--remote" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--xclbin" "--project" "${other_flags[@]}"

            other_flags=( "--device" "--project" )
            command_completion_9 "$cur" "$COMP_CWORD" "program" "vitis" "--xclbin" "--remote" "${other_flags[@]}"
            
            #validate iperf --bandwidth
            other_flags=( "--time" "--udp" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--bandwidth" "--parallel" "${other_flags[@]}"

            other_flags=( "--parallel" "--udp" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--bandwidth" "--time" "${other_flags[@]}"

            other_flags=( "--parallel" "--time" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--bandwidth" "--udp" "${other_flags[@]}"

            #validate iperf --parallel
            other_flags=( "--time" "--udp" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--parallel" "--bandwidth" "${other_flags[@]}"

            other_flags=( "--bandwidth" "--udp" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--parallel" "--time" "${other_flags[@]}"

            other_flags=( "--bandwidth" "--time" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--parallel" "--udp" "${other_flags[@]}"

            #validate iperf --time
            other_flags=( "--parallel" "--udp" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--time" "--bandwidth" "${other_flags[@]}"

            other_flags=( "--bandwidth" "--udp" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--time" "--parallel" "${other_flags[@]}"

            other_flags=( "--bandwidth" "--parallel" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--time" "--udp" "${other_flags[@]}"

            #validate iperf --udp
            other_flags=( "--parallel" "--time" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--udp" "--bandwidth" "${other_flags[@]}"

            other_flags=( "--bandwidth" "--time" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--udp" "--parallel" "${other_flags[@]}"

            other_flags=( "--bandwidth" "--parallel" )
            command_completion_9 "$cur" "$COMP_CWORD" "validate" "iperf" "--udp" "--time" "${other_flags[@]}"
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _sgutil_completions sgutil