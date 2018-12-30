#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=32

exawind_env_common ()
{
    local compiler_env=$1

    module purge
    module load ${compiler_env}

    # Disable use of Intel MKL because of linker issues 
    export EXAWIND_USE_BLASLIB=OFF
}

exawind_env_intel ()
{
    exawind_env_common sierra-devel
    exawind_spack_env intel
    module unload gnu/4.9.2
    module load gcc/4.9.3

    export SPACK_COMPILER=intel
    export CC=$(which mpicc)
    export CXX=$(which mpicxx)
    export F77=$(which mpifort)
    export FC=$(which mpifort)

    exawind_load_deps cmake netlib-lapack zlib libxml2
}

exawind_env_gcc ()
{
    echo "ERROR: No GCC environment setup for ${EXAWIND_SYSTEM}"
    exit 1
}

exawind_env_clang ()
{
    echo "ERROR: No LLVM/Clang environment setup for ${EXAWIND_SYSTEM}"
    exit 1
}
