#!/bin/bash

_sgutil_completions()
{
    local cur

    cur=${COMP_WORDS[COMP_CWORD]}

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
                    COMPREPLY=($(compgen -W "coyote hip mpi vitis --help" -- ${cur}))
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
                            COMPREPLY=($(compgen -W "--platform --project --help" -- ${cur}))
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--project --help" -- ${cur}))
                            ;;
                        mpi)
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        vitis) 
                            COMPREPLY=($(compgen -W "--platform --project --target --help" -- ${cur})) #--xclbin 
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
                program)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        coyote)
                            COMPREPLY=($(compgen -W "--device --project --regions --remote --help" -- ${cur}))
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
                            COMPREPLY=($(compgen -W "--device --project --help" -- ${cur})) 
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--device --project --help" -- ${cur}))
                            ;;
                        mpi)
                            COMPREPLY=($(compgen -W "--project --help" -- ${cur}))
                            ;;
                        vitis)
                            COMPREPLY=($(compgen -W "--config --platform --project --target --help" -- ${cur})) #--device 
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
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
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
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _sgutil_completions sgutil