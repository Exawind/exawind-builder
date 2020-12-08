#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=16

declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[xl]=xl/16.1.1-5
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
    export KOKKOS_ARCH=${KOKKOS_ARCH:-Volta70}
    export EXAWIND_CUDA_SM=${EXAWIND_CUDA_SM:-70}

    # Enable CUDA support in OpenMPI
    export OMPI_MCA_opal_cuda_support=1

    if [ "${EXAWIND_GPU_KOKKOS_ENV:-ON}" = ON ] ; then
        # Set CXX so that NVCC can pick up host compiler
        export CXX=${OMPI_CXX}
        exawind_kokkos_cuda_env
    fi

    # Reset CXX back to mpic++ for builds
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
    module load git

    exawind_load_deps cmake netlib-lapack

    export CC=$(which mpicc)
    export FC=$(which mpifort)
    export CXX=$(which mpic++)

    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    if [ "$ENABLE_CUDA" == "ON" ]; then
        module load ${EXAWIND_MODMAP[cuda]}
        exawind_summit_gpu
    fi
}

exawind_env_intel ()
{
    echo "ERROR: No intel environment setup for ORNL Summit"
    exit 1
}

exawind_env_clang ()
{
    echo "ERROR: No clang environment setup for ORNL Summit"
    exit 1
}

exawind_env_xl ()
{
    module purge
    exawind_summit_common
    module load ${EXAWIND_MODMAP[xl]}

    module load git cmake

    export CC=$(which mpicc)
    export FC=$(which mpifort)
    export CXX=$(which mpic++)

    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    if [ "$ENABLE_CUDA" == "ON" ]; then
        module load ${EXAWIND_MODMAP[cuda]}
        exawind_summit_gpu
    fi
}
