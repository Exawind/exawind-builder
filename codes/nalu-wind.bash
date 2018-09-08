#!/bin/bash

exawind_proj_env ()
{
    local opt_packages=(
        hypre
        openfast
        tioga
    )

    echo "==> Loading dependencies for nalu-wind... "
    exawind_load_deps trilinos yaml-cpp

    for pkg in ${opt_packages[@]} ; do
        local pkg_flag="ENABLE_${pkg^^}"
        if [ "${!pkg_flag:-ON}" = "ON" ] ; then
            exawind_load_deps $pkg
        fi
    done
}

exawind_cmake_base ()
{
    local extra_args="$@"
    local install_dir=""
    if [ -n "$NALU_WIND_INSTALL_PREFIX" ] ; then
        install_dir="-DCMAKE_INSTALL_PREFIX=$NALU_WIND_INSTALL_PREFIX"
    fi


    # Force CMake to use absolute paths for the libraries so that it doesn't
    # pick up versions installed in `/usr/lib64` on peregrine
    local lib_path_save=${LIBRARY_PATH}
    unset LIBRARY_PATH

    local cmake_cmd=(
        cmake
        -DTrilinos_DIR:PATH=${TRILINOS_ROOT_DIR}
        -DYAML_DIR:PATH=${YAML_CPP_ROOT_DIR}
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE}
        -DENABLE_HYPRE:BOOL=${ENABLE_HYPRE:-ON}
        -DHYPRE_DIR:PATH=${HYPRE_ROOT_DIR}
        -DENABLE_TIOGA:BOOL=${ENABLE_TIOGA:-ON}
        -DTIOGA_DIR:PATH=${TIOGA_ROOT_DIR}
        -DENABLE_OPENFAST:BOOL=${ENABLE_OPENFAST:-ON}
        -DOpenFAST_DIR:PATH=${OPENFAST_ROOT_DIR}
        -DENABLE_TESTS:BOOL=${ENABLE_TESTS:-ON}
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON
        ${install_dir}
        ${extra_args}
        ${NALU_WIND_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    export LIBRARY_PATH=${lib_path_save}
}

exawind_cmake_osx ()
{
    local extra_args="$@"
    exawind_cmake_base \
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON \
        -DMPIEXEC_PREFLAGS:STRING='"--use-hwthread-cpus --oversubscribe"' \
        ${extra_args}
}

exawind_cmake_cori ()
{
    local extra_args="$@"
    exawind_cmake_base \
        -DMPIEXEC_NUMPROC_FLAG="-n" \
        ${extra_args}
}
