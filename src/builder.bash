#!/bin/bash

__EXAWIND_CORESRC_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
__EXAWIND_CORE_DIR=${__EXAWIND_CORE_DIR:-$(dirname ${__EXAWIND_CORESRC_DIR})}

# Build directories that must be removed when performing cmake_full
declare -a _EXAWIND_PROJECT_CMAKE_RMEXTRA_

exawind_get_compiler_flags ()
{
    local cxxflags=${CMAKE_CXX_FLAGS:-$CXXFLAGS}
    local fflags=${CMAKE_Fortran_FLAGS:-$FFLAGS}
    local cflags=${CMAKE_C_FLAGS:-$CFLAGS}

    if [ -n "${EXAWIND_ARCH_FLAGS}" ] ; then
        cxxflags="${cxxflags} ${EXAWIND_ARCH_FLAGS}"
        cflags="${cflags} ${EXAWIND_ARCH_FLAGS}"
        fflags="${fflags} ${EXAWIND_ARCH_FLAGS}"
    fi

    if [ -n "${cxxflags}" ] ; then
        local compiler_flags=(
            -DCMAKE_CXX_FLAGS="'${cxxflags}'"
            -DCMAKE_C_FLAGS="'${cflags}'"
            -DCMAKE_Fortran_FLAGS="'${fflags}'"
        )

        echo "${compiler_flags[@]}"
    fi
}

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
        make_type=${EXAWIND_MAKE_TYPE:-auto}
        case ${make_type} in
            "ninja")
                cmake_option="-G Ninja"
                ;;
            "make")
                cmake_option="-G 'Unix Makefiles'"
                ;;
            "auto")
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

exawind_num_parjobs ()
{
    local num_tasks=${EXAWIND_NUM_JOBS:-$EXAWIND_NUM_JOBS_DEFAULT}
    local cmd_args="$*"

    local par_args=$(echo ${cmd_args} | sed -n -e 's/^.*\(-j *[[:digit:]]*\).*$/\1/p')
    local other_args=$(echo ${cmd_args} | sed 's/-j *[[:digit:]]*//')
    if [ "${#par_args}"  = "0" ] ; then
        par_args="-j ${num_tasks}"
    fi

    echo "${par_args} ${other_args}"
}

exawind_make ()
{
    local num_tasks=${EXAWIND_NUM_JOBS:-$EXAWIND_NUM_JOBS_DEFAULT}
    local make_type=$(exawind_guess_make_type)

    if [ "$#" == "0" ] ; then
        extra_args="-j ${num_tasks}"
    else
        extra_args=$(exawind_num_parjobs "$*")
    fi

    echo "+ ${make_type} ${extra_args}"
    case ${make_type} in
        *ninja | *make)
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

    if [ "$#" == "0" ] ; then
        extra_args="-j ${num_tasks}"
    else
        extra_args=$(exawind_num_parjobs "$*")
    fi

    command ctest --output-on-failure ${extra_args}
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
