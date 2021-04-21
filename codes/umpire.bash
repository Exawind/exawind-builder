#!/bin/bash

export EXAWIND_GPU_KOKKOS_ENV=OFF

exawind_proj_env ()
{
    echo "==> Umpire: No additional dependencies"
}

exawind_umpire_fix_gpu ()
{
    if [ "${EXAWIND_GPU_KOKKOS_ENV:-OFF}" = "ON" ] ; then
      echo "ERROR: Cannot build umpire with Kokkos nvcc_wrapper"
      exit 1
    fi
    unset EXAWIND_CUDA_WRAPPER
    unset NVCC_WRAPPER_DEFAULT_COMPILER

    export CUDA_HOME=${CUDA_HOME:-$(dirname $(dirname $(which nvcc)))}
}


exawind_cmake_base ()
{
    local extra_args="$@"
    local install_dir=""

    # Force CMake to use absolute paths for the libraries so that it doesn't
    # pick up versions installed in `/usr/lib64` on peregrine
    local lib_path_save=${LIBRARY_PATH}
    unset LIBRARY_PATH

    if [ -n "$UMPIRE_INSTALL_PREFIX" ] ; then
        install_dir="$UMPIRE_INSTALL_PREFIX"
    else
        install_dir="$(cd .. && pwd)/install"
    fi

    if [ "${ENABLE_CUDA:-OFF}" = "ON" ] ; then 
        echo "==> UMPIRE: Enabling CUDA"
        extra_args='-DCMAKE_CUDA_FLAGS="-arch sm_${EXAWIND_CUDA_ARCH}"'
        exawind_umpire_fix_gpu
    fi

    local cmake_cmd=(
        cmake
        -DCMAKE_INSTALL_PREFIX=${install_dir}
        -DENABLE_CUDA=${ENABLE_CUDA:-OFF}
        -DENABLE_HIP=${ENABLE_HIP:-OFF}
        -DENABLE_C=${ENABLE_C:-ON}
	-DCMAKE_VERBOSE_MAKEFILE=${ENABLE_VERBOSE:-OFF}
        ${extra_args}
        ${UMPIRE_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    export LIBRARY_PATH=${lib_path_save}
}
