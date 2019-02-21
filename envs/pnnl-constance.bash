#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=8

exawind_env_gcc ()
{
    module purge

    module load gcc/7.3.0
    module load openmpi/1.10.1

    # Initialize Spack for this system+compiler configuration
    exawind_spack_env gcc
    # Load default modules for all builds
    exawind_load_deps cmake netlib-lapack

    export CC=$(which mpicc)
    export CXX=$(which mpicxx)
    export FC=$(which mpifort)
}
