#!/bin/bash

exawind_proj_env ()
{
    echo "==> Loading dependencies for arborx..."
    exawind_load_deps trilinos
}

exawind_cmake_base ()
{
    local extra_args="$@"
    local install_dir=""
    if [ -n "$ARBORX_INSTALL_PREFIX" ] ; then
        install_dir="-DCMAKE_INSTALL_PREFIX=$ARBORX_INSTALL_PREFIX"
    fi

    local compiler_flags=$(exawind_get_compiler_flags)

    # Force CMake to use absolute paths for the libraries so that it doesn't
    # pick up versions installed in `/usr/lib64` on peregrine
    local lib_path_save=${LIBRARY_PATH}
    unset LIBRARY_PATH

    local cmake_cmd=(
        cmake
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE}
        -DCMAKE_PREFIX_PATH=${TRILINOS_ROOT_DIR}
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
        -DARBORX_ENABLE_BENCHMARKS=OFF
        -DARBORX_ENABLE_TESTS=OFF
        -DARBORX_ENABLE_EXAMPLES=OFF
        -DMPI_USE_COMPILER_WRAPPERS:BOOL=ON
        -DMPI_CXX_COMPILER:FILEPATH=${MPICXX}
        -DMPI_C_COMPILER:FILEPATH=${MPICC}
        -DMPI_Fortran_COMPILER:FILEPATH=${MPIFC}
        ${compiler_flags}
        ${install_dir}
        ${extra_args}
        ${ARBORX_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    export LIBRARY_PATH=${lib_path_save}
}
