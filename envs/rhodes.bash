#!/bin/bash

EXAWIND_DEP_LOADER=module

exawind_module_env ()
{
    local compiler_arg=$1

    export MODULE_PREFIX=/opt/utilities/modules_prefix
    export PATH=${MODULE_PREFIX}/bin:${PATH}
    local moddate=${EXAWIND_MODULES_SNAPSHOT:-modules}
    module use /opt/compilers/${moddate}
    module use /opt/utilities/${moddate}
    module use /opt/software/${moddate}/${compiler_arg}

    echo "==> Using modules: $(readlink -f /opt/software/${moddate}/${compiler_arg})"
}

module ()
{
    eval $(${MODULE_PREFIX}/bin/modulecmd $(basename ${SHELL}) $*);
}

exawind_env_gcc ()
{
    if [ ! -z ${EXAWIND_RTEST_BUILD} ] ; then
        exawind_env_gcc_test
    else
        exawind_env_gcc_dev
    fi
}

exawind_env_gcc_dev ()
{
    export EXAWIND_GCC_VERSION=${EXAWIND_GCC_VERSION:-7.4.0}
    exawind_module_env gcc-${EXAWIND_GCC_VERSION}
    module purge
    module load gcc/${EXAWIND_GCC_VERSION}
    module load binutils cmake openmpi

    export CC=$(which mpicc)
    export CXX=$(which mpicxx)
    export FC=$(which mpifort)
}

exawind_env_gcc_test ()
{
    # Force gold version build
    export EXAWIND_DEP_LOADER=spack
    export EXAWIND_GCC_VERSION=4.9.4
    export SPACK_COMPILER=gcc@${EXAWIND_GCC_VERSION}
    export MODULE_PREFIX=/opt/utilities/modules_prefix
    export PATH=${MODULE_PREFIX}/bin:${PATH}
    local moddate=modules-2019-05-08
    module use /opt/compilers/${moddate}
    module use /opt/utilities/${moddate}

    module load git
    # Force loading test spack project
    source /projects/ecp/exawind/nalu-wind-testing/spack/share/spack/setup-env.sh
    export SPACK_EXE=${SPACK_ROOT}/bin/spack
    exawind_load_deps cmake 
    exawind_load_deps openmpi@3.1.4

    export CC=$(which mpicc)
    export CXX=$(which mpicxx)
    export FC=$(which mpifort)
}

exawind_env_intel ()
{
    exawind_module_env intel-18.0.4
    module purge
    module load gcc/7.4.0
    module load intel-parallel-studio
    module load binutils cmake intel-mpi intel-mkl

    export CC=$(which mpiicc)
    export CXX=$(which mpiicpc)
    export FC=$(which mpiifort)
}
