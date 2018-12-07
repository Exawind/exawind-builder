#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=24

# Mapping identifying versions to load for each dependency
declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[trilinos]=trilinos/develop

EXAWIND_DEP_LOADER=module

exawind_peregrine_common ()
{
    local compiler_arg=$1

    export EXAWIND_MODULES_DIR=/nopt/nrel/ecom/hpacf
    local moddate=${EXAWIND_MODULES_SNAPSHOT:-modules}
    module unuse /nopt/nrel/apps/modules/centos7/modulefiles
    module use ${EXAWIND_MODULES_DIR}/compilers/${moddate}
    module use ${EXAWIND_MODULES_DIR}/utilities/${moddate}
    module use ${EXAWIND_MODULES_DIR}/software/${moddate}/${compiler_arg}

    echo "==> Using modules: $(readlink -f ${EXAWIND_MODULES_DIR}/software/${moddate}/${compiler_arg})"
}

exawind_env_gcc ()
{
    module purge
    exawind_peregrine_common gcc-7.3.0

    module load gcc/7.3.0
    module load binutils openmpi netlib-lapack cmake

    export CC=$(which mpicc)
    export CXX=$(which mpicxx)
    export FC=$(which mpifort)
}

exawind_env_intel ()
{
    module purge
    exawind_peregrine_common intel-18.0.4

    module load intel-parallel-studio
    module load binutils intel-mpi intel-mkl cmake

    export CC=$(which mpiicc)
    export CXX=$(which mpiicpc)
    export FC=$(which mpiifort)
}
