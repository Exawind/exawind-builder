#!/bin/bash

# Exawind builder configuration for SNL waterman
#
# This configuration uses the system modules exclusively for the builds. For a
# build that corresponds to the exact versions of TPLs used for nalu-wind use
# the `waterman` config.
#

source ${__EXAWIND_CORE_DIR}/envs/spack.bash

export EXAWIND_NUM_JOBS_DEFAULT=32

declare -A EXAWIND_MODMAP
EXAWIND_MODMAP[mpi]=openmpi/2.1.2/gcc/7.2.0/cuda/9.2.88
EXAWIND_MODMAP[cuda]=cuda/9.2.88
EXAWIND_MODMAP[cmake]=cmake/3.12.3
EXAWIND_MODMAP[ninja]=ninja/1.7.2
EXAWIND_MODMAP[git]=git/2.10.1
EXAWIND_MODMAP[hdf5]=hdf5/1.8.20/openmpi/2.1.2/gcc/7.2.0/cuda/9.2.88
EXAWIND_MODMAP[parallel-netcdf]=pnetcdf-exo/1.9.0/openmpi/2.1.2/gcc/7.2.0/cuda/9.2.88
EXAWIND_MODMAP[netcdf]=netcdf-exo/4.6.1/openmpi/2.1.2/gcc/7.2.0/cuda/9.2.88
EXAWIND_MODMAP[boost]=boost/1.65.1/gcc/7.2.0
EXAWIND_MODMAP[netlib-lapack]=netlib/3.8.0/gcc/7.2.0
EXAWIND_MODMAP[superlu]=superlu/4.3.0/gcc/7.2.0
EXAWIND_MODMAP[libxml2]=libxml2/2.9.2
EXAWIND_MODMAP[zlib]=zlib/1.2.8

EXAWIND_DEP_LOADER=module

exawind_env_gcc ()
{
    module purge
    local module_list=(
        mpi
        cuda
        cmake
        ninja
        git
        zlib
        libxml2
        hdf5
        netcdf
        parallel-netcdf
        boost
        netlib-lapack
        superlu
    )
    for modname in ${module_list[@]} ; do
        module load ${EXAWIND_MODMAP[${modname}]}
    done
    module list

    export EXAWIND_MAKE_TYPE=${EXAWIND_MAKE_TYPE:-ninja}
    export EXAWIND_CUDA_WRAPPER=${EXAWIND_CUDA_WRAPPER:-${EXAWIND_CUDA_WRAPPER_DEFAULT}}
    export CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING:-1}
    export CUDA_MANAGED_FORCE_DEVICE_ALLOC=${CUDA_MANAGED_FORCE_DEVICE_ALLOC:-1}
    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    export KOKKOS_ARCH=${KOKKOS_ARCH:-Volta70}
    export EXAWIND_CUDA_SM=${EXAWIND_CUDA_SM:-70}

    export CC=$(which mpicc)
    export CXX=$(which g++)
    export F77=$(which mpif90)
    export FC=$(which mpif90)

    export NVCC_WRAPPER_DEFAULT_COMPILER=$CXX
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}
    export CXX=$(which mpic++)

    export HDF5_ROOT_DIR=${HDF5_ROOT_DIR:-${HDF5_ROOT}}
    export NETCDF_ROOT_DIR=${NETCDF_ROOT_DIR:-${NETCDFEXO_ROOT}}
    export PARALLEL_NETCDF_ROOT_DIR=${PARALLEL_NETCDF_ROOT_DIR:-${PNETCDF_ROOT}}
    export BOOST_ROOT_DIR=${BOOST_ROOT_DIR:-${BOOST_ROOT}}
    export SUPERLU_ROOT_DIR=${SUPERLU_ROOT_DIR:-${SUPERLU_ROOT}}
    export ZLIB_ROOT_DIR=${ZLIB_ROOT_DIR:-${ZLIB_ROOT}}
    export LIBXML2_ROOT_DIR=${LIBXML2_ROOT_DIR:-${LIBXML2_ROOT}}

    # Fix BLAS/LAPACK paths (the ROOT is the same)
    local blaslib_local="'-L${BLAS_ROOT}/lib;-llapack;-lblas;-lgfortran;-lgomp;-lm'"
    export BLASLIB=${BLASLIB:-${blaslib_local}}
    export EXAWIND_USE_BLASLIB=${EXAWIND_USE_BLASLIB:-ON}

    # Fix duplicate libraries issue
    export EXAWIND_NVCC_EXTRA_FLAGS="--remove-duplicate-link-files'"

    # Fix issue with LIBRARY_PATH on waterman
    export EXAWIND_UNSET_LIBRARY_PATH=${EXAWIND_UNSET_LIBRARY_PATH:-OFF}

    # Check and warn regarding yaml-cpp
    if [ -z "${YAML_CPP_ROOT_DIR}" ] ; then
        echo "==> WARNING: Cannot find yaml-cpp; set YAML_CPP_ROOT_DIR to install path"
    fi

    echo "==> Activated GCC+CUDA environment for SNL waterman"
}
