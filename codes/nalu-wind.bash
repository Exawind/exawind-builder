#!/bin/bash

exawind_proj_env ()
{
    exawind_load_deps hypre openfast tioga trilinos yaml-cpp
}

exawind_cmake ()
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

    command cmake \
        -DTrilinos_DIR:PATH=${TRILINOS_ROOT_DIR} \
        -DYAML_DIR:PATH=${YAML_CPP_ROOT_DIR} \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE} \
        -DENABLE_HYPRE:BOOL=${ENABLE_HYPRE:-ON} \
        -DHYPRE_DIR:PATH=${HYPRE_ROOT_DIR} \
        -DENABLE_TIOGA:BOOL=${ENABLE_TIOGA:-ON} \
        -DTIOGA_DIR:PATH=${TIOGA_ROOT_DIR} \
        -DENABLE_OPENFAST:BOOL=${ENABLE_OPENFAST:-ON} \
        -DOpenFAST_DIR:PATH=${OPENFAST_ROOT_DIR} \
        -DENABLE_TESTS:BOOL=ON \
        ${install_dir} \
        ${extra_args} \
        ${NALU_SOURCE_DIR:-..} 2>&1 | tee cmake_output.log

    export LIBRARY_PATH=${lib_path_save}
}
