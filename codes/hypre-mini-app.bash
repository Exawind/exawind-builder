#!/bin/bash

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    src
    deps
)

exawind_proj_env ()
{
    exawind_load_deps hypre yaml-cpp
}

exawind_cmake_base ()
{
    local extra_args="$@"
    local install_dir="${HYPRE_MINI_APP_INSTALL_PREFIX:-../install}"

    # Force CMake to use absolute paths for the libraries so that it doesn't
    # pick up versions installed in `/usr/lib64` on peregrine
    local lib_path_save=${LIBRARY_PATH}
    unset LIBRARY_PATH

    local cmake_cmd=(
        cmake
        -DCMAKE_INSTALL_PREFIX=${install_dir}
        -DHYPRE_DIR=${HYPRE_ROOT_DIR}
        ${extra_args}
        ${HYPRE_MINI_APP_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    export LIBRARY_PATH=${lib_path_save}
}
