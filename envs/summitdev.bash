#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=32

exawind_env_gcc ()
{
    echo "ERROR: No GCC environment setup for SummitDev"
}

exawind_env_intel ()
{
    echo "ERROR: No GCC environment setup for SummitDev"
}

exawind_env_xl ()
{
    if [ -z "${OLCF_XL_ROOT}" ] ; then
        module load DefApps
    fi

    module load cmake/3.11.3
    module load cuda

    export SPACK_ROOT=${SPACK_ROOT:-/ccs/proj/csc249/exawind/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack
    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)

    export EXAWIND_COMPILER=xl
    export CC=$(which xlc)
    export CXX=$(which xlc++)
    export F77=$(which xlf)
    export FC=$(which xlf2003)
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${!root_dir_var} ] ; then
            module load $(${SPACK_EXE} module find $depname %${EXAWIND_COMPILER})
            eval "export $root_dir_var=$(${SPACK_EXE} location -i $depname %${EXAWIND_COMPILER})"
        fi
    done
}
