#!/bin/bash

__EXAWIND_CORE_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

source ${__EXAWIND_CORE_DIR}/src/environment.bash
source ${__EXAWIND_CORE_DIR}/src/builder.bash

exawind_help ()
{
    cat <<EOF
Exawind build script

Usage:
    ${0} <task> <arguments>

With no tasks provided, the script will configure the project and compile the code

Available tasks:
    cmake       - configure the project
    cmake_full  - configure project after removing CMakeCache
    make        - compile the code
    ctest       - run tests (if available)
    run         - run arbitrary command using the environment used to compile the code
EOF
}

exawind_save_func ()
{
    local orig_func=$(declare -f $1)
    local new_func="$2${orig_func#$1}"
    eval "$new_func"
}

exawind_main ()
{
    if [ "$#" == "0" ] ; then
        exawind_env && exawind_proj_env && exawind_cmake && exawind_make
    else
        subcmd=$1

        case ${subcmd} in
            "-h" | "--help" | "-?")
                exawind_help
                exit 0
                ;;
            *)
                shift
                exawind_env && exawind_proj_env && exawind_${subcmd} "$@"

                if [ $? = 127 ] ; then
                    echo "ERROR: ${subcmd} is not a valid command."
                    exawind_help
                fi
                ;;
        esac
    fi
}

