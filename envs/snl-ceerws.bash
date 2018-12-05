#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=32

exawind_env_common ()
{
    local compiler_env=$1

    module purge
    module load ${compiler_env}
    # Spack has issues with the default 2.7 python from sierra-devel
    module unload sierra-python/2.7
    module load sierra-python/3.6.3

    export SPACK_ROOT=${SPACK_ROOT:-${EXAWIND_PROJECT_DIR}/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack
    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)
}

exawind_env_gcc ()
{
    exawind_env_common sierra-devel

    export SPACK_COMPILER=gcc
    export CC=$(which mpicc)
    export CXX=$(which mpicxx)
    export F77=$(which mpifort)
    export FC=$(which mpifort)

    exawind_load_deps cmake netlib-lapack zlib libxml2
}

exawind_env_intel ()
{
    exawind_env_common sierra-devel/intel

    export SPACK_COMPILER=intel
    export CC=$(which mpiicc)
    export CXX=$(which mpicxx)
    export F77=$(which mpifort)
    export FC=$(which mpifort)

    exawind_load_deps cmake zlib libxml2
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
