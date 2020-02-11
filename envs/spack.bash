#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=8

# Handle name change for netcdf
EXAWIND_MODMAP[netcdf]=netcdf-c

exawind_spack_env ()
{
    export SPACK_ROOT=${SPACK_ROOT:-${EXAWIND_PROJECT_DIR}/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack

    local compiler_arg=$1
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-$compiler_arg}
    export SPACK_COMPILER=${SPACK_COMPILER:-${EXAWIND_COMPILER}}

    if [[ $OSTYPE = "darwin"* ]] ; then
        local brew_prefix=$(brew config | awk -F: '/HOMEBREW_PREFIX/ {gsub("^ *", "", $2); print $2;}')

        # Exit early if we cannot find the right module command
        if [ ! -d ${brew_prefix}/opt/modules/init ] ; then
          echo "ERROR: Cannot find module command. 'brew install modules'"
          exit 1
        fi

        # Source based on bash or zsh (Catalina defaults)
        if [ -n "${ZSH_NAME}" ] ; then
          . /usr/local/opt/modules/init/zsh
        else
          source /usr/local/opt/modules/init/bash
        fi

        export EXAWIND_NUM_JOBS_DEFAULT=4
    fi
    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)

    echo "==> Using spack configuration: ${SPACK_ROOT}"
}

exawind_env_gcc ()
{
    exawind_spack_env gcc

    if [[ $OSTYPE = "darwin"* ]] ; then
        exawind_load_deps mpi cmake netlib-lapack
    fi
}

exawind_env_intel ()
{
    if [[ $OSTYPE = "darwin"* ]] ; then
        echo "ERROR: Intel compiler not supported on OSX"
        exit 1
    else
        exawind_spack_env intel
    fi
}

exawind_env_clang ()
{
    exawind_spack_env clang

    if [[ $OSTYPE = "darwin"* ]] ; then
        exawind_load_deps mpi cmake netlib-lapack
    fi
}
