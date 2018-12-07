#!/bin/bash

exawind_proj_env ()
{
    echo "==> Loading dependencies for wind-utils..."
    exawind_load_deps zlib libxml2 hdf5 trilinos yaml-cpp
}

exawind_cmake_base ()
{
    local extra_args="$@"
    local install_dir=""
    if [ -n "$WIND_UTILS_INSTALL_PREFIX" ] ; then
        install_dir="-DCMAKE_INSTALL_PREFIX=$WIND_UTILS_INSTALL_PREFIX"
    fi

    local compiler_flags=$(exawind_get_compiler_flags)

    # Force CMake to use absolute paths for the libraries so that it doesn't
    # pick up versions installed in `/usr/lib64` on peregrine
    local lib_path_save=${LIBRARY_PATH}
    unset LIBRARY_PATH

    local cmake_cmd=(
        cmake
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE}
        -DTrilinos_DIR:PATH=${TRILINOS_ROOT_DIR}
        -DYAML_ROOT:PATH=${YAML_CPP_ROOT_DIR}
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE
        ${compiler_flags}
        ${install_dir}
        ${extra_args}
        ${WIND_UTILS_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    export LIBRARY_PATH=${lib_path_save}
}
