#!/bin/bash

export EXAWIND_NUM_JOBS=36
export EXAWIND_MODULES_DIR=/nopt/nrel/ecom/hpacf/2018-11-09/spack/share/spack/modules/linux-centos7-x86_64/

declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[trilinos]=trilinos/develop

exawind_env_gcc ()
{
    module purge
    module load gcc/7.3.0
    module use ${EXAWIND_MODULES_DIR}/gcc-7.3.0

    module load binutils openmpi/3.1.3 netlib-lapack/3.8.0 cmake/3.12.3

    export CC=$(which gcc)
    export CXX=$(which g++)
    export FC=$(which gfortran)

    echo "==> Using modules: $(readlink -f ${EXAWIND_MODULES_DIR}/gcc-7.3.0)"
}

exawind_env_intel ()
{
    echo "ERROR: No Intel environment set up for NREL Eagle"
    exit 1
}

exawind_env_clang ()
{
    echo "ERROR: No Intel environment set up for NREL Eagle"
    exit 1
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${!root_dir_var} ] ; then
            module load ${depname}
        fi
        echo "==> ${depname} = ${!root_dir_var}"
    done
}
