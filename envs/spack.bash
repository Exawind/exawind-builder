#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=8

exawind_spack_env ()
{
    export SPACK_ROOT=${SPACK_ROOT:-${EXAWIND_PROJECT_DIR}/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack

    if [[ $OSTYPE = "darwin"* ]] ; then
        if [ -f /usr/local/opt/modules/init/bash ]; then
            source /usr/local/opt/modules/init/bash
        else
            echo "ERROR: Cannot find module command. brew install modules"
        fi
    fi
    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)

    echo "==> Using spack configuration: ${SPACK_ROOT}"
}

exawind_env_gcc ()
{
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-gcc}
    export SPACK_COMPILER=${SPACK_COMPILER:-${EXAWIND_COMPILER}}
    exawind_spack_env
}

exawind_env_intel ()
{
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-intel}
    export SPACK_COMPILER=${SPACK_COMPILER:-${EXAWIND_COMPILER}}
    exawind_spack_env
}

exawind_env_clang ()
{
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-clang}
    export SPACK_COMPILER=${SPACK_COMPILER:-${EXAWIND_COMPILER}}
    exawind_spack_env
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${!root_dir_var} ] ; then
            module load $(${SPACK_EXE} module tcl find $depname %${SPACK_COMPILER})
            eval "export $root_dir_var=$(${SPACK_EXE} location -i $depname %${SPACK_COMPILER})"
        fi
        echo "==> ${depname} = ${!root_dir_var}"
    done
}
