#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=8
export EXAWIND_COMPILER_DEFAULT=intel

exawind_env_gcc ()
{
    echo "ERROR: No GCC environment set up for Cori"
    exit 1
}

exawind_env_clang ()
{
    echo "ERROR: No CLANG environment set up for Cori"
    exit 1
}

exawind_env_intel ()
{
    if [ -z "${CRAY_PRGENVINTEL}" ] ; then
       module load PrgEnv-intel/6.0.4
    fi

    export CC=$(which cc)
    export CXX=$(which CC)
    export FC=$(which ftn)
    export BLASLIB="$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_intel.a"

    exawind_spack_env intel

    exawind_load_deps cmake
}
