#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=32

exawind_env_common ()
{
    if [ -z "${OLCF_SPECTRUM_MPI_ROOT}" ] ; then
        module load DefApps
    fi

    module load cmake/3.11.3
    module load cuda

    export SPACK_ROOT=${SPACK_ROOT:-/ccs/proj/csc249/exawind/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack
    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)
}

exawind_env_gcc ()
{
    exawind_env_common

    module load gcc/7.1.0

    export SPACK_COMPILER=xl
    export CC=${OMPI_CC}
    export CXX=${OMPI_CXX}
    export F77=${OMPI_FC}
    export FC=${OMPI_FC}

    exawind_load_deps netlib-lapack zlib libxml2
}

exawind_env_intel ()
{
    echo "ERROR: No GCC environment setup for SummitDev"
}

exawind_env_xl ()
{
    exawind_env_common

    export SPACK_COMPILER=xl
    export EXAWIND_COMPILER=xl
    export CC=$(which xlc)
    export CXX=$(which xlc++)
    export F77=$(which xlf)
    export FC=$(which xlf2003)

    exawind_load_deps netlib-lapack zlib libxml2
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${!root_dir_var} ] ; then
            module load $(${SPACK_EXE} module find $depname %${SPACK_COMPILER})
            eval "export $root_dir_var=$(${SPACK_EXE} location -i $depname %${SPACK_COMPILER})"
        fi
    done
}
