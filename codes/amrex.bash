#!/bin/bash

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    Src
    Tools
)

declare -A EXAWIND_AMREX_CUDA_MAP
EXAWIND_AMREX_CUDA_MAP[70]=Volta

exawind_proj_env ()
{
    echo "==> No additional dependencies supported for AMReX"
}

exawind_cmake_base ()
{
    local extra_args="$@"
    AMREX_INSTALL_PREFIX=${AMREX_INSTALL_PREFIX:-${EXAWIND_INSTALL_DIR}/amrex}

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
        -DCMAKE_INSTALL_PREFIX=${AMREX_INSTALL_PREFIX}
        -DDIM=3
        -DENABLE_ACC=OFF
        -DENABLE_AMRDATA=OFF
        -DENABLE_ASSERTIONS=OFF
        -DENABLE_BACKTRACE=OFF
        -DENABLE_BASE_PROFILE=OFF
        -DENABLE_COMM_PROFILE=OFF
        -DENABLE_CONDUIT=OFF
        -DENABLE_CUDA=${ENABLE_CUDA:-OFF}
        -DENABLE_DP=ON
        -DENABLE_EB=OFF
        -DENABLE_FORTRAN=${AMREX_ENABLE_FORTRAN:-OFF}
        -DENABLE_FORTRAN_INTERFACES=${AMREX_ENABLE_FORTRAN:-OFF}
        -DENABLE_FPE=OFF
        -DENABLE_LINEAR_SOLVERS=ON
        -DENABLE_MEM_PROFILE=OFF
        -DENABLE_MPI=${AMREX_ENABLE_MPI:-ON}
        -DENABLE_OMP=${ENABLE_OPENMP:-OFF}
        -DENABLE_PARTICLES=ON
        -DENABLE_PIC=ON
        -DENABLE_PLOTFILE_TOOLS=ON
        -DENABLE_PROFPARSER=OFF
        -DENABLE_SENSEI_INSITU=OFF
        -DENABLE_SUNDIALS=OFF
        -DENABLE_TINY_PROFILE=OFF
        -DUSE_XSDK_DEFAULTS=OFF
        ${python_exec}
        ${compiler_flags}
        ${extra_args}
        ${AMREX_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    if [ "${EXAWIND_UNSET_LIBRARY_PATH:-ON}" = "ON" ] ; then
        export LIBRARY_PATH=${lib_path_save}
    fi
}
