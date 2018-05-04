#!/bin/bash

exawind_proj_env ()
{
    exawind_load_deps zlib libxml2 hdf5 yaml-cpp
}

exawind_cmake ()
{
    local extra_args="$@"

    cmake \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DFPE_TRAP_ENABLED:BOOL=ON \
        -DBUILD_FAST_CPP_API:BOOL=ON \
        -DYAML_ROOT:PATH=${YAML_ROOT_DIR} \
        -DHDF5_ROOT:PATH=${HDF5_ROOT_DIR} \
        ${extra_args} ..
}
