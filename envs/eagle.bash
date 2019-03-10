#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=36

declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[trilinos]=trilinos/develop
EXAWIND_MODMAP[cuda]=cuda/10.0.130
EXAWIND_MODMAP[mpi]=mpich/3.3

EXAWIND_DEP_LOADER=module

exawind_eagle_common ()
{
    local compiler_arg=$1

    export EXAWIND_MODULES_DIR=/nopt/nrel/ecom/hpacf
    local moddate=${EXAWIND_MODULES_SNAPSHOT:-modules}

    if [ ! -z "$MODULEPATH" ] ; then
        module unuse $MODULEPATH
    fi

    module use ${EXAWIND_MODULES_DIR}/compilers/${moddate}
    module use ${EXAWIND_MODULES_DIR}/utilities/${moddate}
    module use ${EXAWIND_MODULES_DIR}/software/${moddate}/${compiler_arg}

    if [ ! -z "${EXAWIND_EXTRA_MODDIRS}" ] ; then
        module use ${EXAWIND_EXTRA_MODDIRS}
    fi

    echo "==> Using modules: $(readlink -f ${EXAWIND_MODULES_DIR}/software/${moddate}/${compiler_arg})"
}

exawind_eagle_gpu ()
{
    # Enable CUDA support in OpenMPI
    export OMPI_MCA_opal_cuda_support=1

    export EXAWIND_CUDA_WRAPPER=${EXAWIND_CUDA_WRAPPER:-${EXAWIND_PROJECT_DIR}/source/trilinos/packages/kokkos/bin/nvcc_wrapper}
    export CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING:-1}
    export CUDA_MANAGED_FORCE_DEVICE_ALLOC=${CUDA_MANAGED_FORCE_DEVICE_ALLOC:-1}
    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    export KOKKOS_ARCH=${KOKKOS_ARCH:-Volta70}
    export EXAWIND_CUDA_SM=${EXAWIND_CUDA_SM:-70}

    export NVCC_WRAPPER_DEFAULT_COMPILER=${CXX}
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}
    export CXX=$(which mpic++)
    export CUDACXX=$(which nvcc)

    echo "==> Activated Eagle CUDA programming environment"
}

exawind_env_gcc ()
{
    module purge
    exawind_eagle_common gcc-7.3.0

    module load gcc/7.3.0
    exawind_load_deps binutils ${EXAWIND_MODMAP[mpi]} cmake netlib-lapack/3.8.0

    export F77=$(which mpifort)
    export FC=$(which mpifort)
    if [ "${ENABLE_CUDA:-OFF}" = "OFF" ] ; then
        export CC=$(which mpicc)
        export CXX=$(which mpic++)

        # Suppress warnings about CUDA when running on standard nodes
        export OMPI_MCA_opal_cuda_support=0

        # Set arch flags for optimization
        # export EXAWIND_ARCH_FLAGS="-march=skylake-avx512 -mtune=skylake-avx512"
    else
        exawind_load_deps cuda
        export CC=$(which gcc)
        export CXX=$(which g++)
        exawind_eagle_gpu
    fi

    # Supress warnings issued because of ulimit issues on Eagle when using MPICH
    export MXM_LOG_LEVEL=error
}

exawind_env_intel ()
{
    module purge
    exawind_eagle_common intel-18.0.4

    module load gcc/7.3.0
    module load intel-parallel-studio
    exawind_load_deps binutils cmake intel-mpi intel-mkl

    export F77=$(which mpiifort)
    export FC=$(which mpiifort)
    if [ "${ENABLE_CUDA:-OFF}" = "OFF" ] ; then
       export CC=$(which mpiicc)
       export CXX=$(which mpiicpc)

       # Suppress warnings about CUDA when running on standard nodes
       export OMPI_MCA_opal_cuda_support=0

       #export EXAWIND_ARCH_FLAGS="-xSKYLAKE-AVX512"
    else
        echo "==> WARNING: Support for CUDA with Intel compilers not tested"
        exawind_load_deps cuda
        export CC=$(which icc)
        export CXX=$(which icpc)
        exawind_eagle_gpu
    fi

    export _EXAWIND_MKL_LIBNAMES="'mkl_intel_lp64;mkl_sequential;mkl_core;pthread;m;dl'"
    export EXAWIND_MKL_LIBNAMES=${EXAWIND_MKL_LIBNAMES:-${_EXAWIND_MKL_LIBNAMES}}
    export EXAWIND_MKL_LIBDIRS=${EXAWIND_MKL_LIBDIRS:-${MKLROOT}/lib/intel64}
}

exawind_env_clang ()
{
    echo "ERROR: No Intel environment set up for NREL Eagle"
    exit 1
}
