#!/bin/bash

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=16

declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[xl]=xl/16.1.1-10
EXAWIND_DEP_LOADER=module

exawind_summit_common ()
{
    if [ -z "${OLCF_SPECTRUM_MPI_ROOT}" ] ; then
        module load DefApps
    fi
}

exawind_load_system_modules ()
{
    local pkg_name="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')"
    root_dir_var="${pkg_name}_ROOT_DIR"
    if [ ${pkg_name} == "MPI" ] ; then
        local olcf_var="OLCF_SPECTRUM_${pkg_name}_ROOT"
    else
        local olcf_var="OLCF_${pkg_name}_ROOT"
    fi
    eval "export root_dir_var=\"\${$olcf_var}\""
}

exawind_summit_gpu ()
{
    export KOKKOS_ARCH=${KOKKOS_ARCH:-Volta70}
    export EXAWIND_CUDA_SM=${EXAWIND_CUDA_SM:-70}

    # Enable CUDA support in OpenMPI
    export OMPI_MCA_opal_cuda_support=1

    if [ "${EXAWIND_GPU_KOKKOS_ENV:-ON}" = ON ] ; then
        # Set CXX so that NVCC can pick up host compiler
        export CXX=${OMPI_CXX}
        exawind_kokkos_cuda_env
        # Reset CXX back to mpic++ for builds
        export CXX=${MPICXX}
    fi

    export CUDACXX=$(which nvcc)

    echo "==> Activated Summit CUDA programming environment"
}

exawind_env_gcc ()
{
    module purge
    exawind_summit_common
    #exawind_spack_env gcc
    exawind_load_deps mpi gcc cuda cmake netlib-lapack hdf5

    export EXAWIND_GCC_VERSION=${EXAWIND_GCC_VERSION:-9.3.0}

    export CXX=$(which g++)
    export CC=$(which gcc)
    export FC=$(which gfortran)
    export F77=$(which gfortran)

    export MPICXX=$(which mpicxx)
    export MPICC=$(which mpicc)
    export MPIFC=$(which mpif90)

    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    if [ "$ENABLE_CUDA" == "ON" ]; then
        module load ${EXAWIND_MODMAP[cuda]}
        exawind_summit_gpu
    fi
}

exawind_env_intel ()
{
    echo "ERROR: No intel environment setup for ORNL Summit"
    exit 1
}

exawind_env_clang ()
{
    echo "ERROR: No clang environment setup for ORNL Summit"
    exit 1
}

exawind_env_xl ()
{
    module purge
    exawind_summit_common
    module load ${EXAWIND_MODMAP[xl]}

    module load git cmake

    export CXX=$(which xlc++)
    export CC=$(which xlc)
    export FC=$(which xlf95)
    export F77=$(which xlf)

    export MPICXX=$(which mpic++)
    export MPICC=$(which mpicc)
    export MPIFC=$(which mpifort)

    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    if [ "$ENABLE_CUDA" == "ON" ]; then
        module load ${EXAWIND_MODMAP[cuda]}
        exawind_summit_gpu
    fi
}
