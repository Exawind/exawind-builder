#!/bin/bash

exawind_proj_env ()
{
    exawind_load_deps trilinos yaml-cpp
}

exawind_cmake ()
{
    local extra_args="$@"
    local install_dir=""
    if [ -n "$WIND_UTILS_INSTALL_PREFIX" ] ; then
        install_dir="-DCMAKE_INSTALL_PREFIX=\"$WIND_UTILS_INSTALL_PREFIX\""
    fi

    command cmake \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE} \
        -DTrilinos_DIR:PATH=${TRILINOS_ROOT_DIR} \
        -DYAML_ROOT:PATH=${YAML_CPP_ROOT_DIR} \
        ${install_dir} \
        ${extra_args} ..
}
