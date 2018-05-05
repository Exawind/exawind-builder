#!/bin/bash

exawind_proj_env ()
{
    exawind_load_deps trilinos yaml-cpp tioga nalu-wind
}

exawind_cmake ()
{
    local extra_args="$@"

    command cmake \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE} \
        -DTrilinos_DIR:PATH=${TRILINOS_ROOT_DIR} \
        -DYAML_DIR:PATH=${YAML_CPP_ROOT_DIR} \
        -DNALU_DIR:PATH=${NALU_WIND_ROOT_DIR} \
        ${extra_args} ../src
}
