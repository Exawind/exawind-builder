#!/bin/bash

# Throttle max number of jobs to ensure fortran modules build properly
export EXAWIND_NUM_JOBS_DEFAULT=8

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    modules-local
    modules-ext
    glue-codes
    ftnmods
)

exawind_proj_env ()
{
    if [ "${FAST_CPP_API:-ON}" = "ON" ] ; then
        echo "==> Loading dependencies for OpenFAST... "
        exawind_load_deps zlib libxml2 hdf5 yaml-cpp
    else
        echo "==> FAST C++ API is disabled. No additional dependencies."
    fi

    export EXAWIND_MAKE_TYPE=make
}

exawind_cmake_base ()
{
    local extra_args_inp=( "$@" )
    local extra_args=""
    local install_dir=""
    if [ -n "$OPENFAST_INSTALL_PREFIX" ] ; then
        install_dir="$OPENFAST_INSTALL_PREFIX"
    else
        install_dir="$(cd .. && pwd)/install"
    fi

    # OpenFAST cannot handle Ninja builds if testing is enabled and it needs to
    # compile pfUnit, so disable any Ninja arguments.
    if [[ $extra_args_inp[0] = -G* ]] ; then
        extra_args=${extra_args_inp[@]:1}
    else
        extra_args=${extra_args_inp}
    fi

    local compiler_flags=$(exawind_get_compiler_flags)

    # Configure BLAS/LAPACK if user has setup the BLASLIB variable
    local blas_lapack=""
    if [ -n "$BLASLIB" ] ; then
        blas_lapack="-DBLAS_LIBRARIES=$BLASLIB -DLAPACK_LIBRARIES=$BLASLIB"
    fi

    if [ "${FAST_CPP_API:-ON}" = "OFF" ] ; then
        echo "==> OpenFAST: Disabling C++ API"
    fi

    # Force CMake to use absolute paths for the libraries so that it doesn't
    # pick up versions installed in `/usr/lib64` on peregrine
    local lib_path_save=${LIBRARY_PATH}
    unset LIBRARY_PATH

    local cmake_cmd=(
        cmake
        -DCMAKE_INSTALL_PREFIX:PATH=${install_dir}
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE}
        -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS:-OFF}
        -DFPE_TRAP_ENABLED:BOOL=ON
        -DUSE_DLL_INTERFACE:BOOL=ON
        -DBUILD_FAST_CPP_API:BOOL=${FAST_CPP_API:-ON}
        -DBUILD_OPENFAST_CPP_API:BOOL=${FAST_CPP_API:-ON}
        -DYAML_ROOT:PATH=${YAML_CPP_ROOT_DIR}
        -DHDF5_ROOT:PATH=${HDF5_ROOT_DIR}
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON
        ${blas_lapack}
        ${compiler_flags}
        ${extra_args[@]}
        ${OPENFAST_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    export LIBRARY_PATH=${lib_path_save}
}

exawind_make ()
{
    local num_tasks=${EXAWIND_NUM_JOBS:-$EXAWIND_NUM_JOBS_DEFAULT}

    if [ "$#" == "0" ] ; then
        extra_args="-j ${num_tasks}"
    else
        extra_args="$@"
    fi

    command make ${extra_args} 2>&1 | tee make_output.log
}
