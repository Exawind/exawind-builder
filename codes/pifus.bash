#!/bin/bash

exawind_proj_env ()
{
    echo "==> PIFUS: No additional dependencies"
}

exawind_cmake_base ()
{
    local extra_args="$@"
    local install_dir=""
    if [ -n "$PIFUS_INSTALL_PREFIX" ] ; then
        install_dir="-DCMAKE_INSTALL_PREFIX=$PIFUS_INSTALL_PREFIX"
    fi

    local compiler_flags=$(exawind_get_compiler_flags)

    local cmake_cmd=(
        cmake
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
        -DBUILD_GPU_CODE=${ENABLE_CUDA:-OFF}
        -DPIFUS_CUDA_SM=${EXAWIND_CUDA_SM:-60}
        ${install_dir}
        ${compiler_flags}
        ${extra_args}
        ${PIFUS_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log
}
