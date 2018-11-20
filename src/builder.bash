#!/bin/bash

__EXAWIND_CORESRC_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
__EXAWIND_CORE_DIR=${__EXAWIND_CORE_DIR:-$(dirname ${__EXAWIND_CORESRC_DIR})}

# Build directories that must be removed when performing cmake_full
declare -a _EXAWIND_PROJECT_CMAKE_RMEXTRA_

exawind_cmake_full ()
{
    set +e
    rm -rf CMakeCache.txt CMakeFiles *.cmake *Makefile* *.ninja
    if [ "${#_EXAWIND_PROJECT_CMAKE_RMEXTRA_[@]}" -gt 0 ] ; then
        rm -rf "${_EXAWIND_PROJECT_CMAKE_RMEXTRA_[@]}"
    fi
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
