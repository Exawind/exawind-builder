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
        masa
        hypre
    )

    echo "==> Loading dependencies for amr-wind ... "
    exawind_load_deps netcdf-c
    for pkg in ${opt_packages[@]} ; do
        local pkg_flag="ENABLE_${pkg^^}"
        if [ "${!pkg_flag:-OFF}" = "ON" ] ; then
            exawind_load_deps $pkg
        fi
    done
    export NETCDF_ROOT_DIR=${NETCDF_ROOT_DIR:-${NETCDF_C_ROOT_DIR}}
}

exawind_cmake_base ()
{
    local extra_args="$@"
    local ccache_args=""
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

    if [ "${ENABLE_CCACHE:-OFF}" = "ON" ] ; then
        ccache_args="-DCMAKE_CXX_COMPILER_LAUNCHER:STRING=$(which ccache)"
    fi


    local cmake_cmd=(
        cmake
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE}
        -DCMAKE_INSTALL_PREFIX=${AMR_WIND_INSTALL_PREFIX}
        -DAMR_WIND_ENABLE_CUDA=${ENABLE_CUDA:-OFF}
        -DCUDA_ARCH=${EXAWIND_AMR_WIND_CUDA_MAP[${EXAWIND_CUDA_SM:-70}]}
        -DAMR_WIND_ENABLE_MPI:BOOL=${AMR_WIND_ENABLE_MPI:-ON}
        -DAMR_WIND_ENABLE_OPENMP:BOOL=${ENABLE_OPENMP:-OFF}
        -DAMR_WIND_ENABLE_NETCDF:BOOL=ON
        -DNETCDF_DIR:PATH=${NETCDF_ROOT_DIR}
        -DAMR_WIND_ENABLE_MASA:BOOL=${ENABLE_MASA:-OFF}
        -DMASA_DIR:PATH=${MASA_ROOT_DIR}
        -DAMR_WIND_ENABLE_HYPRE=${ENABLE_HYPRE}
        -DHYPRE_ROOT=${HYPRE_ROOT_DIR}
        -DAMR_WIND_ENABLE_ALL_WARNINGS:BOOL=ON
        -DAMR_WIND_ENABLE_FCOMPARE:BOOL=${AMR_WIND_ENABLE_FCOMPARE:-ON}
        -DAMR_WIND_ENABLE_TESTS:BOOL=ON
        -DAMR_WIND_TEST_WITH_FCOMPARE:BOOL=${AMR_WIND_TEST_WITH_FCOMPARE:-ON}
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
        ${python_exec}
        ${ccache_args}
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
