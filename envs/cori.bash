#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=8

exawind_env_gcc ()
{
    echo "ERROR: No GCC environment set up for Cori"
    exit 1
}

exawind_env_intel ()
{
    if [ -z "${CRAY_PRGENVINTEL}" ] ; then
       module load PrgEnv-intel/6.0.4
    fi

    module load cmake/3.8.2
    module load zlib/1.2.8
    module load cray-parallel-netcdf/1.8.1.3
    module load cray-netcdf-hdf5parallel/4.4.1.1.3
    module load cray-hdf5-parallel/1.10.1.1
    module load boost/1.63
    module load libxml2/2.9.3

    export CC=cc
    export CXX=CC
    export FC=ftn
    export BLASLIB="$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_intel.a"

    export PARALLEL_NETCDF_ROOT=${PARALLEL_NETCDF_DIR}
    export NETCDF_ROOT=${NETCDF_DIR}
}

exawind_load_deps () {

    for dep in $@ ; do
        mod_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')"
        root_dir_var="${mod_var}_ROOT_DIR"
        root_var="${mod_var}_ROOT"

        if [ -n "${!root_dir_var}" ] ; then continue ; fi

        if [ -z ${!root_var} ] ; then
            module load $dep
        fi
        eval "export $root_dir_var=${!root_var}"
    done
}
