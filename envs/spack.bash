#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=8

exawind_spack_env ()
{
    export SPACK_ROOT=${SPACK_ROOT:-${EXAWIND_PROJECT_DIR}/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack

    local compiler_arg=$1
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-$compiler_arg}
    export SPACK_COMPILER=${SPACK_COMPILER:-${EXAWIND_COMPILER}}

    if [[ $OSTYPE = "darwin"* ]] ; then
        if [ -f /usr/local/opt/modules/init/bash ]; then
            source /usr/local/opt/modules/init/bash
        else
            echo "ERROR: Cannot find module command. brew install modules"
        fi
        export EXAWIND_NUM_JOBS_DEFAULT=4
    fi
    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)

    echo "==> Using spack configuration: ${SPACK_ROOT}"
}

exawind_env_gcc ()
{
    exawind_spack_env gcc

    exawind_load_deps mpi netlib-lapack
}

exawind_env_intel ()
{
    if [[ $OSTYPE = "darwin"* ]] ; then
        echo "ERROR: Intel compiler not supported on OSX"
        exit 1
    else
        exawind_spack_env intel
        exawind_load_deps mpi
    fi
}

exawind_env_clang ()
{
    exawind_spack_env clang

    exawind_load_deps mpi netlib-lapack
}
