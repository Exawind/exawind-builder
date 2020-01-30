#!/bin/bash

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    src
)

declare -A EXAWIND_AMR_WIND_CUDA_MAP
EXAWIND_AMR_WIND_CUDA_MAP[70]=Volta

exawind_proj_env ()
{
    local opt_packages=(
        python
    )

    echo "==> Loading dependencies for amr-wind ... "
    for pkg in ${opt_packages[@]} ; do
        local pkg_flag="ENABLE_${pkg^^}"
        if [ "${!pkg_flag:-OFF}" = "ON" ] ; then
            exawind_load_deps $pkg
        fi
    done
}

exawind_cmake_base ()
{
    local extra_args="$@"
    AMR_WIND_INSTALL_PREFIX=${AMR_WIND_INSTALL_PREFIX:-${EXAWIND_INSTALL_DIR}/amr-wind}

    local compiler_flags=$(exawind_get_compiler_flags)
    local python_exec=" "
    if [ "${ENABLE_PYTHON:-OFF}" = "ON" ] ; then
        python_exec="-DPYTHON_EXECUTABLE=$(which python3)"
    fi

    if [ "${EXAWIND_UNSET_LIBRARY_PATH:-ON}" = "ON" ] ; then
        # Force CMake to use absolute paths for the libraries so that it doesn't
        # pick up versions installed in `/usr/lib64` on peregrine
        local lib_path_save=${LIBRARY_PATH}
        unset LIBRARY_PATH
    fi

    local cmake_cmd=(
        cmake
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE}
        -DCMAKE_INSTALL_PREFIX=${AMR_WIND_INSTALL_PREFIX}
        -DENABLE_CUDA=${ENABLE_CUDA:-OFF}
        -DCUDA_ARCH=${EXAWIND_AMR_WIND_CUDA_MAP[${EXAWIND_CUDA_SM:-70}]}
        -DAMR_WIND_ENABLE_MPI:BOOL=ON
        -DAMR_WIND_ENABLE_EB:BOOL=${AMR_WIND_ENABLE_EB:-OFF}
        -DAMR_WIND_ENABLE_FCOMPARE:BOOL=${AMR_WIND_ENABLE_FCOMPARE:-OFF}
        -DAMR_WIND_ENABLE_FEXTREMA:BOOL=${AMR_WIND_ENABLE_FEXTREMA:-OFF}
        -DAMR_WIND_ENABLE_TESTS:BOOL=ON
        -DAMR_WIND_TEST_WITH_FCOMPARE:BOOL=${AMR_WIND_TEST_WITH_FCOMPARE:-OFF}
        -DAMR_WIND_TEST_WITH_FEXTREMA:BOOL=${AMR_WIND_TEST_WITH_FEXTREMA:-OFF}
        -DAMR_WIND_DIM:STRING=3
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
        ${python_exec}
        ${compiler_flags}
        ${extra_args}
        ${AMR_WIND_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    if [ "${EXAWIND_UNSET_LIBRARY_PATH:-ON}" = "ON" ] ; then
        export LIBRARY_PATH=${lib_path_save}
    fi
}
