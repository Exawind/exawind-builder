#!/bin/bash

exawind_proj_env ()
{
    exawind_load_deps zlib libxml2 hdf5 yaml-cpp
}

exawind_cmake ()
{
    local extra_args="$@"
    local install_dir=""
    if [ -n "$OPENFAST_INSTALL_PREFIX" ] ; then
        install_dir="$OPENFAST_INSTALL_PREFIX"
    else
        install_dir="$(cd .. && pwd)/install"
    fi

    # Configure BLAS/LAPACK if user has setup the BLASLIB variable
    local blas_lapack=""
    if [ -n "$BLASLIB" ] ; then
        blas_lapack="-DBLAS_LIBRARIES=\"$BLASLIB\" -DLAPACK_LIBRARIES=\"$BLASLIB\""
    fi

    # Force CMake to use absolute paths for the libraries so that it doesn't
    # pick up versions installed in `/usr/lib64` on peregrine
    local lib_path_save=${LIBRARY_PATH}
    unset LIBRARY_PATH

    cmake \
        -DCMAKE_INSTALL_PREFIX:PATH=${install_dir} \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE} \
        -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS:-OFF} \
        -DFPE_TRAP_ENABLED:BOOL=ON \
        -DUSE_DLL_INTERFACE:BOOL=ON \
        -DBUILD_FAST_CPP_API:BOOL=ON \
        -DYAML_ROOT:PATH=${YAML_ROOT_DIR} \
        -DHDF5_ROOT:PATH=${HDF5_ROOT_DIR} \
        ${blas_lapack} \
        ${extra_args} ..

    export LIBRARY_PATH=${lib_path_save}
}
