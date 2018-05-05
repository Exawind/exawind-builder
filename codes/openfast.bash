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

    local rpath_dirs="$(exawind_rpath_dirs zlib libxml2 hdf5 yaml-cpp):${install_dir}/lib"

    # Configure BLAS/LAPACK if user has setup the BLASLIB variable
    local blas_lapack=""
    if [ -n "$BLASLIB" ] ; then
        blas_lapack="-DBLAS_LIBRARIES=\"$BLASLIB\" -DLAPACK_LIBRARIES=\"$BLASLIB\""
    fi

    cmake \
        -DCMAKE_INSTALL_PREFIX:PATH=${install_dir} \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE} \
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE \
        -DCMAKE_INSTALL_RPATH:STRING=${rpath_dirs} \
        -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS:-OFF} \
        -DFPE_TRAP_ENABLED:BOOL=ON \
        -DUSE_DLL_INTERFACE:BOOL=ON \
        -DBUILD_FAST_CPP_API:BOOL=ON \
        -DYAML_ROOT:PATH=${YAML_ROOT_DIR} \
        -DHDF5_ROOT:PATH=${HDF5_ROOT_DIR} \
        ${blas_lapack} \
        ${extra_args} ..
}
