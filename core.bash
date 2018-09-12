#!/bin/bash

__EXAWIND_CORE_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Array holding exact module/spack descriptor for a dependency
declare -A EXAWIND_MODMAP

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

exawind_env ()
{
    local srcdir=${__EXAWIND_CORE_DIR}
    if [ -z "$EXAWIND_SYSTEM" ] ; then
       echo "EXAWIND_SYSTEM variable has not been defined"
       exit 1
    fi

    local sys=${EXAWIND_SYSTEM}
    local compiler=${EXAWIND_COMPILER:-gcc}
    source ${srcdir}/envs/${sys}.bash
    exawind_env_${compiler}
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        if [ -z ${!root_dir_var} ] ; then
            module load ${EXAWIND_MODMAP[$dep]:-$dep}
        fi
    done
}

exawind_cmake_full ()
{
    set +e
    rm -rf CMakeCache.txt CMakeFiles Makefile *.ninja
    set -e
    exawind_cmake "$@"
}

exawind_cmake ()
{
    local cmake_option=" "

    if [ ! -e "CMakeCache.txt" ] ; then
        make_type=${EXAWIND_MAKE_TYPE:-make}
        case ${make_type} in
            "ninja")
                cmake_option="-G Ninja"
                ;;
            "make")
                cmake_option="-G 'Unix Makefiles'"
                ;;
            *)
                echo "!!ERROR!! Unknown CMake generator provided: ${make_type}"
                ;;
        esac
    fi

    if [ "$(uname)" = "Darwin" -a "$(type -t exawind_cmake_osx)" = "function" ] ; then
        exawind_cmake_osx "${cmake_option}" "$@"
    elif [ "$(type -t exawind_cmake_${EXAWIND_SYSTEM})" = "function" ] ; then
        exawind_cmake_${EXAWIND_SYSTEM} "${cmake_option}" "$@"
    else
        exawind_cmake_base "${cmake_option}" "$@"
    fi
}

exawind_guess_make_type ()
{
    if [ -e "CMakeCache.txt" ] ; then
        echo "$(awk -F '=' '/CMAKE_MAKE_PROGRAM:FILEPATH/ { print $2 }' CMakeCache.txt)"
    else
        echo "make"
    fi
}

exawind_make ()
{
    local num_tasks=${EXAWIND_NUM_JOBS:-$EXAWIND_NUM_JOBS_DEFAULT}
    local make_type=$(exawind_guess_make_type)

    if [ "$#" == "0" ] ; then
        extra_args="-j ${num_tasks}"
    else
        extra_args="$@"
    fi

    case ${make_type} in
        *ninja)
            command ${make_type} ${extra_args}
            ;;
        *make)
            command ${make_type} ${extra_args} 2>&1 | tee make_output.log
            ;;
        *)
            echo "!!ERROR!! Invalid make type detected"
            exit 1
    esac
}

exawind_ctest ()
{
    export OMP_NUM_THREADS=${OMP_NUM_THREADS:-1};
    export OMP_PROC_BIND=${OMP_PROC_BIND:-true};
    export OMP_PLACES=${OMP_PLACES:-threads}

    local num_tasks=${EXAWIND_NUM_JOBS:-$EXAWIND_NUM_JOBS_DEFAULT}

    if [ "$#" == "0" ] ; then
        extra_args="-j ${num_tasks}"
    else
        extra_args="$@"
    fi

    command ctest ${extra_args}
}

exawind_run ()
{
    export OMP_NUM_THREADS=${OMP_NUM_THREADS:-1};
    export OMP_PROC_BIND=${OMP_PROC_BIND:-true};
    export OMP_PLACES=${OMP_PLACES:-threads}

    echo "+ $@"
    eval "$@"
}

exawind_load_user_configs ()
{
    local cfgname=${EXAWIND_CFGFILE:-exawind-config}
    local global_cfg=${EXAWIND_CONFIG:-${EXAWIND_PROJECT_DIR}/${EXAWIND_CFGFILE}.sh}
    local cfgfiles=(
        ${HOME}/.${cfgname}
        ${global_cfg}
        $(pwd)/${cfgname}.sh
    )

    for cfg in ${cfgfiles[@]}; do
        if [ -f ${cfg} ] ; then
            echo "==> Loading options from ${cfg}"
            source ${cfg}
        fi
    done
}

exawind_rpath_dirs ()
{
    local rpath_dirs=""

    for dep in "$@" ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"
        libpath=${!root_dir_var}/lib
        if [ -d ${libpath} ] ; then
            rpath_dirs=${libpath}:${rpath_dirs}
        fi

        lib64path=${!root_dir_var}/lib64
        if [ -d ${lib64path} ] ; then
            rpath_dirs=${lib64path}:${rpath_dirs}
        fi
    done
    echo $rpath_dirs
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

