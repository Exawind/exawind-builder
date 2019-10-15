#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

EXAWIND_NUM_JOBS_DEFAULT=24

exawind_env_gcc ()
{
    module purge
    module load openmpi/3.1.1/gcc/7.2.0/cuda/9.2.88
    module load git
    module load ninja
    exawind_spack_env gcc

    # Enable CUDA support in OpenMPI
    export OMPI_MCA_opal_cuda_support=1

    export EXAWIND_CUDA_WRAPPER=${EXAWIND_CUDA_WRAPPER:-${EXAWIND_CUDA_WRAPPER_DEFAULT}}
    export CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING:-1}
    export CUDA_MANAGED_FORCE_DEVICE_ALLOC=${CUDA_MANAGED_FORCE_DEVICE_ALLOC:-1}
    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    export KOKKOS_ARCH=${KOKKOS_ARCH:-Volta70}
    export EXAWIND_CUDA_SM=${EXAWIND_CUDA_SM:-70}

    export CC=$(which mpicc)
    export CXX=$(which g++)
    export F77=$(which mpif90)
    export FC=$(which mpif90)

    export NVCC_WRAPPER_DEFAULT_COMPILER=$CXX
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}
    export CXX=$(which mpic++)

    exawind_load_deps cmake netlib-lapack
}
