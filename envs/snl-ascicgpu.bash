#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=32

exawind_env_common ()
{
    module purge
    module load sierra-devel/nvidia
    # Spack has issues with the default 2.7 python from sierra-devel
    module unload sierra-python/2.7
    module load sierra-python/3.6.3

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
    exawind_spack_env gcc

    export CC=$(which gcc)
    export CXX=$(which g++)
    export F77=$(which mpif90)
    export FC=$(which mpif90)

    export NVCC_WRAPPER_DEFAULT_COMPILER=$CXX
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}
    export CXX=$(which mpic++)

    exawind_load_deps cmake netlib-lapack zlib libxml2
}

exawind_env_intel ()
{
    echo "ERROR: No Intel environment setup for snl-ascicgpu"
    exit 1
}

exawind_env_clang ()
{
    echo "ERROR: No LLVM/Clang environment setup for snl-ascicgpu"
    exit 1
}
