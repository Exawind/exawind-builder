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
    local opt_packages=(
        arborx
    )

    echo "==> Loading dependencies for TIOGA..."

    for pkg in ${opt_packages[@]} ; do
        local pkg_flag="ENABLE_${pkg^^}"
        if [ "${!pkg_flag:-OFF}" = "ON" ] ; then
            exawind_load_deps $pkg
        fi
    done

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
        -DTIOGA_ENABLE_ARBORX:BOOL=${ENABLE_ARBORX:-OFF}
        -DCMAKE_PREFIX_PATH="$ARBORX_ROOT_DIR\\;$TRILINOS_ROOT_DIR"
        ${install_dir}
        ${extra_args}
        ${TIOGA_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log
}
