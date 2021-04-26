#!/bin/bash

exawind_proj_env ()
{
    echo "==> Loading dependencies for tioga-utils..."
    exawind_load_deps trilinos yaml-cpp tioga

    if [ "${ENABLE_NALU_WIND:-OFF}" = "ON" ] ; then
        exawind_load_deps nalu-wind
    fi
    if [ "${ENABLE_ARBORX:-OFF}" = "ON" ] ; then
        exawind_load_deps arborx
    fi
}

exawind_cmake_base ()
{
    local extra_args="$@"
    local install_dir=""
    if [ -n "$TIOGA_UTILS_INSTALL_PREFIX" ] ; then
        install_dir="-DCMAKE_INSTALL_PREFIX=$TIOGA_UTILS_INSTALL_PREFIX"
    fi

    cmake_prefix_path=""
    if [ "${ENABLE_ARBORX}" == "ON" ]; then
        cmake_prefix_path="-DCMAKE_PREFIX_PATH=\"$ARBORX_ROOT_DIR\""
    fi


    local compiler_flags=$(exawind_get_compiler_flags)

    # Force CMake to use absolute paths for the libraries so that it doesn't
    # pick up versions installed in `/usr/lib64` on peregrine
    local lib_path_save=${LIBRARY_PATH}
    unset LIBRARY_PATH

    local cmake_cmd=(
        cmake
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE}
        -DTU_ENABLE_CUDA=${ENABLE_CUDA:-OFF}
        -DTU_CUDA_SM=${EXAWIND_CUDA_SM:-70}
        -DAMReX_CUDA_ARCH=${EXAWIND_CUDA_ARCH:-Volta}
        -DTrilinos_DIR:PATH=${TRILINOS_ROOT_DIR}
        -DTIOGA_DIR:PATH=${TIOGA_ROOT_DIR}
        -DYAML_DIR:PATH=${YAML_CPP_ROOT_DIR}
        -DENABLE_NALU_WIND:BOOL=${ENABLE_NALU_WIND:-OFF}
        -DNALU_DIR:PATH=${NALU_WIND_ROOT_DIR}
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
        ${cmake_prefix_path}
        ${compiler_flags}
        ${install_dir}
        ${extra_args}
        ${TIOGA_UTILS_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    export LIBRARY_PATH=${lib_path_save}
}
