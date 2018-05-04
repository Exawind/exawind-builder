#!/bin/bash

export EXAWIND_NUM_JOBS=8

exawind_spack_env ()
{
    export SPACK_ROOT=${SPACK_ROOT:-${HOME}/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack

    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)
}

exawind_env_gcc ()
{
    export EXAWIND_COMPILER=gcc
    exawind_spack_env
}

exawind_env_intel ()
{
    export EXAWIND_COMPILER=intel
    exawind_spack_env
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        if [ -z ${!root_dir_var} ] ; then
            module load $(${SPACK_EXE} module find $dep %${EXAWIND_COMPILER})
            eval "export $root_dir_var=$(${SPACK_EXE} location -i $dep %${EXAWIND_COMPILER})"
        fi
    done
}
