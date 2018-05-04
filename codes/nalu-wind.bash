#!/bin/bash

exawind_proj_env ()
{
    exawind_load_deps hypre openfast tioga trilinos yaml-cpp
}

exawind_cmake ()
{
    local extra_args="$@"

    command cmake \
        -DTrilinos_DIR:PATH=${TRILINOS_ROOT_DIR} \
        -DYAML_DIR:PATH=${YAML_ROOT_DIR} \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DENABLE_HYPRE:BOOL=ON \
        -DHYPRE_DIR:PATH=${HYPRE_ROOT_DIR} \
        -DENABLE_TIOGA:BOOL=ON \
        -DTIOGA_DIR:PATH=${TIOGA_ROOT_DIR} \
        -DENABLE_OPENFAST:BOOL=ON \
        -DOpenFAST_DIR:PATH=${OPENFAST_ROOT_DIR} \
        -DENABLE_TESTS:BOOL=ON \
        ${extra_args} ..
}
