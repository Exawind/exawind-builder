#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=32

exawind_env_common ()
{
    if [ -z "${OLCF_SPECTRUM_MPI_ROOT}" ] ; then
        module load DefApps
    fi

    module load cmake/3.11.3
    module load cuda

    export EXAWIND_CUDA_WRAPPER=${EXAWIND_CUDA_WRAPPER:-${EXAWIND_PROJECT_DIR}/source/trilinos/packages/kokkos/bin/nvcc_wrapper}
    export CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING:-1}
    export CUDA_MANAGED_FORCE_DEVICE_ALLOC=${CUDA_MANAGED_FORCE_DEVICE_ALLOC:-1}
    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    export KOKKOS_ARCH=${KOKKOS_ARCH:-Pascal60}
    export HYPRE_CUDA_SM=${HYPRE_CUDA_SM:-60}
}

exawind_env_gcc ()
{
    exawind_env_common
    module load gcc/5.4.0
    exawind_spack_env gcc

    export CC=${OMPI_CC}
    export CXX=${OMPI_CXX}
    export F77=${OMPI_FC}
    export FC=${OMPI_FC}

    export NVCC_WRAPPER_DEFAULT_COMPILER=${OMPI_CXX}
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}
    export CXX=$(which mpic++)

    exawind_load_deps netlib-lapack zlib libxml2
}

exawind_env_intel ()
{
    echo "ERROR: No Intel environment setup for SummitDev"
}

exawind_env_xl ()
{
    exawind_env_common

    export SPACK_COMPILER=xl
    export EXAWIND_COMPILER=xl
    export CC=${OMPI_CC}
    export CXX=${OMPI_CXX}
    export F77=${OMPI_FC}
    export FC=${OMPI_FC}

    export NVCC_WRAPPER_DEFAULT_COMPILER=${OMPI_CXX}
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}

    exawind_load_deps netlib-lapack zlib libxml2
}
