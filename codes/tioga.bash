#!/bin/bash

exawind_proj_env ()
{
    echo "no additional dependencies"
}

exawind_cmake ()
{
    local extra_args="$@"
    local install_dir=""
    if [ -n "$TIOGA_INSTALL_PREFIX" ] ; then
        install_dir="-DCMAKE_INSTALL_PREFIX=$TIOGA_INSTALL_PREFIX"
    fi

    local cmake_cmd=(
        cmake
        ${install_dir}
        ${extra_args}
        ${TIOGA_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log
}
