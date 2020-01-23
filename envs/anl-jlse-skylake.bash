#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=32

exawind_anl_jlse_common_env ()
{
    export PATH=/soft/compilers/gcc/7.4.0/linux-rhel7-x86_64/bin:${PATH}
    export LD_LIBRARY_PATH=/soft/compilers/gcc/7.4.0/linux-rhel7-x86_64/lib:${LD_LIBRARY_PATH}
    export LD_LIBRARY_PATH=/soft/compilers/gcc/7.4.0/linux-rhel7-x86_64/lib64:${LD_LIBRARY_PATH}
    export LD_LIBRARY_PATH=/soft/compilers/gcc/7.4.0/linux-rhel7-x86_64/libexec:${LD_LIBRARY_PATH}

    export SPACK_ROOT=${SPACK_ROOT:-${EXAWIND_PROJECT_DIR}/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack

    local compiler_arg=$1
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-$compiler_arg}
    export SPACK_COMPILER=${SPACK_COMPILER:-${EXAWIND_COMPILER}}

    export EXAWIND_MODULES=${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)
    module use ${EXAWIND_MODULES}

    exawind_load_deps openmpi cmake netlib-lapack

    export CC=$(which mpicc)
    export CXX=$(which mpicxx) 
    export F77=$(which mpif90)
    export FC=$(which mpif90)

    echo "==> Using modules: ${EXAWIND_MODULES}"
}

exawind_env_gcc ()
{
    exawind_anl_jlse_common_env gcc
}

exawind_env_intel ()
{
    echo "ERROR: No Intel environment setup for jlse-skylake"
    exit 1
}

exawind_env_clang ()
{
    echo "ERROR: No LLVM/Clang environment setup for jlse-skylake"
    exit 1
}
