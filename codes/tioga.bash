#!/bin/bash

# Throttle max processors for fortran build with modules
export EXAWIND_NUM_JOBS_DEFAULT=4

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    src
    driver
    gridGen
)

exawind_proj_env ()
{
    echo "==> TIOGA: No additional dependencies"
}

exawind_cmake_base ()
{
    local extra_args="$@"
    local install_dir=""
    if [ -n "$TIOGA_INSTALL_PREFIX" ] ; then
        install_dir="-DCMAKE_INSTALL_PREFIX=$TIOGA_INSTALL_PREFIX"
    fi

    local cmake_cmd=(
        cmake
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE}
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
        ${install_dir}
        ${extra_args}
        ${TIOGA_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log
}
