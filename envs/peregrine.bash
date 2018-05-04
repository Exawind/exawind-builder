#!/bin/bash

export EXAWIND_NUM_JOBS=24

exawind_env_gcc ()
{
    module purge
    module use /nopt/nrel/apps/modules/candidate/modulefiles/

    module load gcc/5.2.0
    module unuse /nopt/nrel/ecom/ecp/base/modules/intel-17.0.2
    module use /nopt/nrel/ecom/ecp/base/modules/gcc-5.2.0

    module load binutils openmpi netlib-lapack cmake

    export CC=gcc
    export CXX=g++
    export FC=gfortran
}

exawind_env_intel ()
{
    module purge
    module use /nopt/nrel/apps/modules/candidate/modulefiles/
    module load comp-intel/2017.0.2
    module unuse /nopt/nrel/ecom/ecp/base/modules/gcc-5.2.0
    module use /nopt/nrel/ecom/ecp/base/modules/intel-17.0.2

    module load binutils intel-mpi intel-mkl cmake

    export CC=icc
    export CXX=icpc
    export FC=ifort
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        if [ -z ${!root_dir_var} ] ; then
            module load $dep
        fi
    done
}
