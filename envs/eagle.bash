#!/bin/bash

export EXAWIND_NUM_JOBS=36
export EXAWIND_MODULES_DIR=/nopt/nrel/ecom/hpacf/2018-11-09/spack/share/spack/modules/linux-centos7-x86_64

declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[trilinos]=trilinos/develop

EXAWIND_DEP_LOADER=module

exawind_eagle_gpu ()
{
    export EXAWIND_CUDA_WRAPPER=${EXAWIND_CUDA_WRAPPER:-${EXAWIND_PROJECT_DIR}/source/trilinos/packages/kokkos/bin/nvcc_wrapper}
    export CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING:-1}
    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    export KOKKOS_ARCH=${KOKKOS_ARCH:-Volta70}
    export HYPRE_CUDA_SM=${HYPRE_CUDA_SM:-70}

    export NVCC_WRAPPER_DEFAULT_COMPILER=${CXX}
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}
    export CXX=$(which mpic++)
    export CUDACXX=$(which nvcc)

    echo "==> Activated CUDA programming environment"
}

exawind_env_gcc ()
{
    module purge
    module load gcc/7.3.0
    module load cuda/10.0.130
    module use ${EXAWIND_MODULES_DIR}/gcc-7.3.0

    module load binutils openmpi netlib-lapack/3.8.0 cmake/3.12.3

    export F77=$(which mpifort)
    export FC=$(which mpifort)
    if [ "${ENABLE_CUDA:-OFF}" = "OFF" ] ; then
        export CC=$(which mpicc)
        export CXX=$(which mpic++)
    else
        export CC=$(which gcc)
        export CXX=$(which g++)
        exawind_eagle_gpu
    fi

    echo "==> Using modules: $(readlink -f ${EXAWIND_MODULES_DIR}/gcc-7.3.0)"
}

exawind_env_intel ()
{
    echo "ERROR: No Intel environment set up for NREL Eagle"
    exit 1
}

exawind_env_clang ()
{
    echo "ERROR: No Intel environment set up for NREL Eagle"
    exit 1
}
