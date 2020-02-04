#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=32
EXAWIND_MODMAP[netcdf]=netcdf-c

exawind_anl_jlse_gpu_v100_smx2_common_env ()
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

    if [ ! -z "$MODULEPATH" ] ; then
        module unuse $MODULEPATH
    fi

    module use ${EXAWIND_MODULES}
    module purge

    echo "==> Using modules: ${EXAWIND_MODULES}"
}

exawind_env_gpu ()
{
    # Enable CUDA support in OpenMPI
    #export OMPI_MCA_opal_cuda_support=1

    export EXAWIND_CUDA_WRAPPER=${EXAWIND_CUDA_WRAPPER:-${EXAWIND_CUDA_WRAPPER_DEFAULT}}
    export CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING:-1}
    export CUDA_MANAGED_FORCE_DEVICE_ALLOC=${CUDA_MANAGED_FORCE_DEVICE_ALLOC:-1}
    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    export KOKKOS_ARCH=${KOKKOS_ARCH:-"'SKX;Volta70'"}
    export EXAWIND_CUDA_SM=${EXAWIND_CUDA_SM:-70}

    export NVCC_WRAPPER_DEFAULT_COMPILER=${CXX}
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}
    export MPICH_CXX=${EXAWIND_CUDA_WRAPPER}
    export CXX=$(which mpicxx)
    export CUDACXX=$(which nvcc)

    echo "==> Activated CUDA programming environment"
}

exawind_env_gcc ()
{
    export EXAWIND_GCC_VERSION=${EXAWIND_GCC_VERSION:-7.4.0}
    exawind_anl_jlse_gpu_v100_smx2_common_env gcc
    exawind_load_deps cmake netlib-lapack openmpi

    export CXX=$(which g++)
    export CC=$(which mpicc)
    export FC=$(which mpifort)
    export F77=$(which mpif90)

    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    if [ "$ENABLE_CUDA" == "ON" ]; then
        exawind_load_deps cuda
        exawind_env_gpu
    fi
}

exawind_env_intel ()
{
    echo "ERROR: No Intel environment setup for jlse-gpu_v100_smx2"
    exit 1
}

exawind_env_clang ()
{
    echo "ERROR: No LLVM/Clang environment setup for jlse-gpu_v100_smx2"
    exit 1
}
