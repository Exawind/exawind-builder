#!/bin/bash

export EXAWIND_NUM_JOBS=36

declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[trilinos]=trilinos/develop

EXAWIND_DEP_LOADER=module

exawind_eagle_common ()
{
    local compiler_arg=$1

    export EXAWIND_MODULES_DIR=/nopt/nrel/ecom/hpacf
    local moddate=${EXAWIND_MODULES_SNAPSHOT:-modules}
    module unuse /nopt/nrel/apps/modules/default/modulefiles
    module unuse /usr/share/Modules/modulefiles
    module unuse /nopt/modulefiles
    module use ${EXAWIND_MODULES_DIR}/compilers/${moddate}
    module use ${EXAWIND_MODULES_DIR}/utilities/${moddate}
    module use ${EXAWIND_MODULES_DIR}/software/${moddate}/${compiler_arg}

    echo "==> Using modules: $(readlink -f ${EXAWIND_MODULES_DIR}/software/${moddate}/${compiler_arg})"
}

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

    echo "==> Activated Eagle CUDA programming environment"
}

exawind_env_gcc ()
{
    module purge
    exawind_eagle_common gcc-7.3.0

    module load gcc/7.3.0
    module load binutils openmpi cmake netlib-lapack/3.8.0

    export F77=$(which mpifort)
    export FC=$(which mpifort)
    if [ "${ENABLE_CUDA:-OFF}" = "OFF" ] ; then
        export CC=$(which mpicc)
        export CXX=$(which mpic++)
    else
        module load cuda/10.0.130
        export CC=$(which gcc)
        export CXX=$(which g++)
        exawind_eagle_gpu
    fi
}

exawind_env_intel ()
{
    module purge
    exawind_eagle_common intel-18.0.4

    module load intel-parallel-studio
    module load binutils cmake intel-mpi intel-mkl

    export F77=$(which mpiifort)
    export FC=$(which mpiifort)
    if [ "${ENABLE_CUDA:-OFF}" = "OFF" ] ; then
       export CC=$(which mpiicc)
       export CXX=$(which mpiicxx)
    else
        echo "==> WARNING: Support for CUDA with Intel compilers not tested"
        module load cuda/10.0.130
        export CC=$(which icc)
        export CXX=$(which icpc)
        exawind_eagle_gpu
    fi
}

exawind_env_clang ()
{
    echo "ERROR: No Intel environment set up for NREL Eagle"
    exit 1
}
