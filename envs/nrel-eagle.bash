#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=18

declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[cuda]=cuda@10.2.89
EXAWIND_MODMAP[gcc]=gcc/8.4.0
EXAWIND_MODMAP[netcdf]=netcdf-c

EXAWIND_DEP_LOADER=spack
export EXAWIND_PYVENV_SPEC_DEFAULT=${__EXAWIND_CORE_DIR}/etc/python/eagle/requirements.txt

exawind_eagle_common ()
{
    export EXAWIND_MODULES_DIR=/nopt/nrel/ecom/hpacf
    local moddate=${EXAWIND_MODULES_SNAPSHOT:-modules-2020-07}

    if [ ! -z "$MODULEPATH" ] ; then
        module unuse $MODULEPATH
    fi

    module use ${EXAWIND_MODULES_DIR}/binaries/${moddate}
    module use ${EXAWIND_MODULES_DIR}/compilers/${moddate}
    module use ${EXAWIND_MODULES_DIR}/utilities/${moddate}
    module use ${EXAWIND_MODULES_DIR}/software/${moddate}

    if [ ! -z "${EXAWIND_EXTRA_MODDIRS}" ] ; then
        module use ${EXAWIND_EXTRA_MODDIRS}
    fi

    echo "==> Using modules: $(readlink -f ${EXAWIND_MODULES_DIR}/software/${moddate})"
}

exawind_eagle_gpu ()
{
    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    export KOKKOS_ARCH=${KOKKOS_ARCH:-"'SKX;Volta70'"}
    export EXAWIND_CUDA_SM=${EXAWIND_CUDA_SM:-70}

    if [ "${EXAWIND_GPU_KOKKOS_ENV:-ON}" = ON ] ; then
        # Set CXX so that NVCC can pick up host compiler
        export CXX=$(which g++)
        exawind_kokkos_cuda_env
    fi

    export CXX=$(which mpicxx)
    export CUDACXX=$(which nvcc)

    echo "==> Activated Eagle CUDA programming environment"
}

exawind_env_gcc ()
{
    module purge
    export EXAWIND_GCC_VERSION=${EXAWIND_GCC_VERSION:-8.4.0}
    exawind_eagle_common
    exawind_spack_env gcc

    exawind_load_modules gcc git binutils
    exawind_load_deps mpi cmake netlib-lapack/3.8.0

    export F77=$(which mpif77)
    export FC=$(which mpif90)
    export CC=$(which mpicc)
    if [ "${ENABLE_CUDA:-OFF}" = "OFF" ] ; then
        export CXX=$(which mpicxx)

        # Suppress warnings about CUDA when running on standard nodes
        export OMPI_MCA_opal_cuda_support=0

        # Set arch flags for optimization
        export EXAWIND_ARCH_FLAGS_DEFAULT="-march=skylake -mtune=skylake"
        export EXAWIND_ARCH_FLAGS=${EXAWIND_ARCH_FLAGS:-${EXAWIND_ARCH_FLAGS_DEFAULT}}
        export KOKOS_ARCH=${KOKKOS_ARCH:-SKX}
    else
        exawind_load_deps cuda
        export CXX=$(which g++)
        exawind_eagle_gpu
    fi

    # Supress warnings issued because of ulimit issues on Eagle when using MPICH
    export MXM_LOG_LEVEL=error
}

exawind_env_intel ()
{
    module purge
    exawind_eagle_common
    exawind_spack_env gcc

    exawind_load_modules gcc intel-parallel-studio git binutils
    exawind_load_deps cmake intel-mpi netlib-lapack

    export F77=$(which mpiifort)
    export FC=$(which mpiifort)
    export CC=$(which mpiicc)
    if [ "${ENABLE_CUDA:-OFF}" = "OFF" ] ; then
       export CXX=$(which mpiicpc)

       # Suppress warnings about CUDA when running on standard nodes
       export OMPI_MCA_opal_cuda_support=0

       export EXAWIND_ARCH_FLAGS_DEFAULT="-xSKYLAKE-AVX512"
       export EXAWIND_ARCH_FLAGS=${EXAWIND_ARCH_FLAGS:-${EXAWIND_ARCH_FLAGS_DEFAULT}}
       export KOKOS_ARCH=${KOKKOS_ARCH:-SKX}
    else
        echo "==> WARNING: Support for CUDA with Intel compilers not tested"
        exawind_load_deps cuda
        export CXX=$(which icpc)
        exawind_eagle_gpu
    fi

    export _EXAWIND_MKL_LIBNAMES="'mkl_intel_lp64;mkl_sequential;mkl_core;pthread;m;dl'"
    export EXAWIND_MKL_LIBNAMES=${EXAWIND_MKL_LIBNAMES:-${_EXAWIND_MKL_LIBNAMES}}
    export EXAWIND_MKL_LIBDIRS=${EXAWIND_MKL_LIBDIRS:-${MKLROOT}/lib/intel64}
}

exawind_env_clang ()
{
    module purge
    export EXAWIND_GCC_VERSION=${EXAWIND_GCC_VERSION:-8.4.0}
    export EXAWIND_CLANG_VERSION=${EXAWIND_CLANG_VERSION:-10.0.0}
    exawind_eagle_common
    exawind_spack_env gcc

    exawind_load_modules gcc llvm git binutils
    exawind_load_deps mpi cmake netlib-lapack

    export F77=$(which mpif77)
    export FC=$(which mpif90)
    export CC=$(which mpicc)

    # Override C/C++ compilers with LLVM
    export OMPI_CXX=$(which clang++)
    export OMPI_CC=$(which clang)
    export MPICH_CXX=$(which clang++)
    export MPICH_CC=$(which clang)
    export MPICC_CC=$(which clang)
    export MPICXX_CXX=$(which clang++)
    if [ "${ENABLE_CUDA:-OFF}" = "OFF" ] ; then
        export CXX=$(which mpicxx)

        # Suppress warnings about CUDA when running on standard nodes
        export OMPI_MCA_opal_cuda_support=0

        # Set arch flags for optimization
        export EXAWIND_ARCH_FLAGS_DEFAULT="-march=skylake -mtune=skylake"
        export EXAWIND_ARCH_FLAGS=${EXAWIND_ARCH_FLAGS:-${EXAWIND_ARCH_FLAGS_DEFAULT}}
        export KOKOS_ARCH=${KOKKOS_ARCH:-SKX}
    else
        exawind_load_deps cuda
        export CXX=$(which clang++)
        exawind_eagle_gpu
    fi

    # Supress warnings issued because of ulimit issues on Eagle when using MPICH
    export MXM_LOG_LEVEL=error
}

_exw_pyvenv_init ()
{
    export PATH=${EXAWIND_PROJECT_DIR}/python/${EXAWIND_COMPILER}/exw-base/bin:${PATH}
    exawind_load_deps texlive
}
