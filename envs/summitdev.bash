#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=32

exawind_env_common ()
{
    if [ -z "${OLCF_SPECTRUM_MPI_ROOT}" ] ; then
        module load DefApps
    fi

    module load cmake/3.11.3
    module load cuda

    export SPACK_ROOT=${SPACK_ROOT:-${EXAWIND_PROJECT_DIR}/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack
    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)

    export EXAWIND_CUDA_WRAPPER=${EXAWIND_CUDA_WRAPPER:-${EXAWIND_PROJECT_DIR}/source/trilinos/packages/kokkos/bin/nvcc_wrapper}
    export CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING:-1}
    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
}

exawind_env_gcc ()
{
    exawind_env_common

    module load gcc/5.4.0

    export SPACK_COMPILER=gcc
    export CC=${OMPI_CC}
    export CXX=${OMPI_CXX}
    export F77=${OMPI_FC}
    export FC=${OMPI_FC}

    export NVCC_WRAPPER_DEFAULT_COMPILER=${OMPI_CXX}
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}

    exawind_load_deps netlib-lapack zlib libxml2
}

exawind_env_intel ()
{
    echo "ERROR: No Intel environment setup for SummitDev"
}

exawind_env_xl ()
{
    exawind_env_common

    export SPACK_COMPILER=xl
    export EXAWIND_COMPILER=xl
    export CC=${OMPI_CC}
    export CXX=${OMPI_CXX}
    export F77=${OMPI_FC}
    export FC=${OMPI_FC}

    export NVCC_WRAPPER_DEFAULT_COMPILER=${OMPI_CXX}
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}

    exawind_load_deps netlib-lapack zlib libxml2
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${!root_dir_var} ] ; then
            module load $(${SPACK_EXE} module tcl find $depname %${SPACK_COMPILER})
            eval "export $root_dir_var=$(${SPACK_EXE} location -i $depname %${SPACK_COMPILER})"
        fi
        echo "==> ${depname} = ${!root_dir_var}"
    done
}
