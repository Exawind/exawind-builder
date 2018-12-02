#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=8
export EXAWIND_COMPILER_DEFAULT=intel

exawind_env_gcc ()
{
    echo "ERROR: No GCC environment set up for Cori"
    exit 1
}

exawind_env_clang ()
{
    echo "ERROR: No CLANG environment set up for Cori"
    exit 1
}

exawind_env_intel ()
{
    if [ -z "${CRAY_PRGENVINTEL}" ] ; then
       module load PrgEnv-intel/6.0.4
    fi

    module load cmake/3.11.4

    export CC=$(which cc)
    export CXX=$(which CC)
    export FC=$(which ftn)
    export BLASLIB="$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_intel.a"

    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-intel}
    export SPACK_COMPILER=${SPACK_COMPILER:-${EXAWIND_COMPILER}}
    exawind_spack_env
}

# exawind_load_deps () {

#     for dep in $@ ; do
#         mod_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')"
#         root_dir_var="${mod_var}_ROOT_DIR"
#         root_var="${mod_var}_ROOT"

#         if [ -n "${!root_dir_var}" ] ; then continue ; fi

#         if [ -z ${!root_var} ] ; then
#             module load ${EXAWIND_MODMAP[$dep]:-$dep}
#         fi
#         eval "export $root_dir_var=${!root_var}"
#     done
# }
