#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=24
export EXAWIND_MODULES_DIR=/nopt/nrel/ecom/hpacf

# Mapping identifying versions to load for each dependency
declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[trilinos]=trilinos/develop

exawind_env_gcc ()
{
    module purge
    module unuse /nopt/nrel/apps/modules/centos7/modulefiles
    module use ${EXAWIND_MODULES_DIR}/compilers/modules
    module use ${EXAWIND_MODULES_DIR}/utilities/modules
    module use ${EXAWIND_MODULES_DIR}/software/modules/gcc-7.3.0

    module load binutils openmpi netlib-lapack cmake

    export CC=$(which mpicc)
    export CXX=$(which mpicxx)
    export FC=$(which mpifort)

    echo "==> Using modules: $(readlink -f ${EXAWIND_MODULES_DIR}/gcc-7.3.0)"
}

exawind_env_intel ()
{
    module purge
    module unuse /nopt/nrel/apps/modules/centos7/modulefiles
    module use ${EXAWIND_MODULES_DIR}/compilers/modules
    module use ${EXAWIND_MODULES_DIR}/utilities/modules
    module use ${EXAWIND_MODULES_DIR}/software/modules/intel-18.0.4

    module load binutils intel-mpi/2018.4.274 intel-mkl/2018.4.274 cmake

    export CC=$(which mpiicc)
    export CXX=$(which mpiicpc)
    export FC=$(which mpiifort)

    echo "==> Using modules: $(readlink -f ${EXAWIND_MODULES_DIR}/intel-18.0.4)"
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${!root_dir_var} ] ; then
            module load ${depname}
        fi
        echo "==> ${depname} = ${!root_dir_var}"
    done
}
