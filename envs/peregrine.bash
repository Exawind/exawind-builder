#!/bin/bash

export EXAWIND_NUM_JOBS=24
export EXAWIND_MODULES_DIR=/nopt/nrel/ecom/ecp/base/c/spack/share/spack/modules/linux-centos7-x86_64/

# Mapping identifying versions to load for each dependency
declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[trilinos]=trilinos/develop-omp
EXAWIND_MODMAP[openmpi]=openmpi/1.10.4

exawind_env_gcc ()
{
    module purge
    module load gcc/6.2.0
    module use ${EXAWIND_MODULES_DIR}/gcc-6.2.0

    module load binutils openmpi/1.10.4 netlib-lapack cmake

    export CC=$(which gcc)
    export CXX=$(which g++)
    export FC=$(which gfortran)
}

exawind_env_intel ()
{
    module purge
    module load gcc/6.2.0
    module use ${EXAWIND_MODULES_DIR}/gcc-6.2.0
    module load intel-parallel-studio/cluster.2018.1
    module use ${EXAWIND_MODULES_DIR}/intel-18.1.163

    module load binutils intel-mpi intel-mkl cmake

    export CC=$(which icc)
    export CXX=$(which icpc)
    export FC=$(which ifort)
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        if [ -z ${!root_dir_var} ] ; then
            module load ${EXAWIND_MODMAP[$dep]:-$dep}
        fi
    done
}
