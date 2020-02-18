#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=8

exawind_env_common ()
{
    local compiler_env=$1

    module purge
    module load ${compiler_env}
    # Spack has issues with the default 2.7 python from sierra-devel
    module unload sierra-python/2.7
    module load sierra-python/3.6.10
}

exawind_env_gcc ()
{
    exawind_env_common sierra-devel
    exawind_spack_env gcc

    export CC=$(which mpicc)
    export CXX=$(which mpicxx)
    export F77=$(which mpifort)
    export FC=$(which mpifort)

    exawind_load_deps cmake netlib-lapack zlib libxml2
}

exawind_env_intel ()
{
    exawind_env_common sierra-devel/intel
    exawind_spack_env intel

    export SPACK_COMPILER=intel
    export CC=$(which mpiicc)
    export CXX=$(which mpiicpc)
    export F77=$(which mpiifort)
    export FC=$(which mpiifort)
    exawind_load_deps cmake zlib libxml2
    export _EXAWIND_MKL_LIBNAMES="'mkl_intel_lp64;mkl_sequential;mkl_core;pthread;m;dl'"
    export EXAWIND_MKL_LIBNAMES=${EXAWIND_MKL_LIBNAMES:-${_EXAWIND_MKL_LIBNAMES}}
    export EXAWIND_MKL_LIBDIRS=${EXAWIND_MKL_LIBDIRS:-${MKLHOME}/lib/intel64}

}

exawind_env_clang ()
{
    echo "ERROR: No CLANG environment set up for snl-ceerws"
    exit 1
}
