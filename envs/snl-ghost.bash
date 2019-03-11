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

    export SPACK_COMPILER=intel
    export CC=$(which mpicc)
    export CXX=$(which mpicxx)
    export F77=$(which mpifort)
    export FC=$(which mpifort)

    exawind_load_deps cmake intel-mkl zlib libxml2
    export _EXAWIND_MKL_LIBNAMES="'mkl_intel_lp64;mkl_sequential;mkl_core;pthread;m;dl'"
    export EXAWIND_MKL_LIBNAMES=${EXAWIND_MKL_LIBNAMES:-${_EXAWIND_MKL_LIBNAMES}}
    export EXAWIND_MKL_LIBDIRS=${EXAWIND_MKL_LIBDIRS:-${MKLROOT}/lib/intel64}

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
