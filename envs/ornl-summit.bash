#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=16

declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[gcc]=gcc/7.4.0
EXAWIND_MODMAP[cuda]=cuda/9.2.148

exawind_summit_common ()
{
    if [ -z "${OLCF_SPECTRUM_MPI_ROOT}" ] ; then
        module load DefApps
    fi
}

exawind_summit_gpu ()
{
    # Enable CUDA support in OpenMPI
    export OMPI_MCA_opal_cuda_support=1

    export EXAWIND_CUDA_WRAPPER=${EXAWIND_CUDA_WRAPPER:-${EXAWIND_CUDA_WRAPPER_DEFAULT}}
    export CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING:-1}
    export CUDA_MANAGED_FORCE_DEVICE_ALLOC=${CUDA_MANAGED_FORCE_DEVICE_ALLOC:-1}
    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    export KOKKOS_ARCH=${KOKKOS_ARCH:-Volta72}
    export EXAWIND_CUDA_SM=${EXAWIND_CUDA_SM:-72}

    export NVCC_WRAPPER_DEFAULT_COMPILER=${CXX}
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}
    export MPICH_CXX=${EXAWIND_CUDA_WRAPPER}
    export CXX=$(which mpic++)
    export CUDACXX=$(which nvcc)

    echo "==> Activated Summit CUDA programming environment"
}

exawind_env_gcc ()
{
    module purge
    export EXAWIND_GCC_VERSION=${EXAWIND_GCC_VERSION:-7.4.0}
    exawind_summit_common
    exawind_spack_env gcc
    module load ${EXAWIND_MODMAP[gcc]}
    module load ${EXAWIND_MODMAP[cuda]}
    module load git

    exawind_load_deps cmake netlib-lapack

    export CC=$(which mpicc)
    export FC=$(which mpifort)
    export CXX=$(which g++)
    exawind_summit_gpu
}

exawind_env_intel ()
{
    echo "ERROR: No intel environment setup for ORNL Summit"
}

exawind_env_clang ()
{
    echo "ERROR: No clang environment setup for ORNL Summit"
}

exawind_env_xl ()
{
    echo "ERROR: No xl environment setup for ORNL Summit"
}
