#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=8

exawind_spack_env ()
{
    export SPACK_ROOT=${SPACK_ROOT:-${HOME}/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack

    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)
}

exawind_env_gcc ()
{
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-gcc}
    exawind_spack_env
}

exawind_env_intel ()
{
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-intel}
    exawind_spack_env
}

exawind_env_clang ()
{
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-clang}
    exawind_spack_env
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${!root_dir_var} ] ; then
            module load $(${SPACK_EXE} module find $depname %${EXAWIND_COMPILER})
            eval "export $root_dir_var=$(${SPACK_EXE} location -i $depname %${EXAWIND_COMPILER})"
        fi
    done
}
