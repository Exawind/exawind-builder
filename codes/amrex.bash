#!/bin/bash

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    Src
    Tools
)

declare -A EXAWIND_AMREX_CUDA_MAP
EXAWIND_AMREX_CUDA_MAP[70]=Volta
export EXAWIND_GPU_KOKKOS_ENV=OFF

exawind_proj_env ()
{
    local opt_packages=(
        python
        hypre
    )

    echo "==> Loading dependencies for AMReX ... "
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
        -DAMReX_ACC=OFF
        -DAMReX_AMRDATA=OFF
        -DAMReX_ASCENT=OFF
        -DAMReX_ASSERTIONS=OFF
        -DAMReX_BACKTRACE=OFF
        -DAMReX_BASE_PROFILE=OFF
        -DAMReX_COMM_PROFILE=OFF
        -DAMReX_CONDUIT=OFF
        -DAMReX_CUDA=${ENABLE_CUDA:-OFF}
        -DAMReX_CUDA_ARCH=${AMREX_CUDA_ARCH:7.0}
        -DAMReX_DP=ON
        -DAMReX_EB=OFF
        -DAMReX_FORTRAN=${AMREX_ENABLE_FORTRAN:-OFF}
        -DAMReX_FORTRAN_INTERFACES=${AMREX_ENABLE_FORTRAN:-OFF}
        -DAMReX_FPE=OFF
        -DAMReX_HYPRE=${ENABLE_HYPRE}
        -DHYPRE_ROOT=${HYPRE_ROOT_DIR}
        -DAMReX_LINEAR_SOLVERS=ON
        -DAMReX_MEM_PROFILE=OFF
        -DAMReX_MPI=${AMREX_ENABLE_MPI:-ON}
        -DAMReX_OMP=${ENABLE_OPENMP:-OFF}
        -DAMReX_PARTICLES=ON
        -DAMReX_PIC=ON
        -DAMReX_PLOTFILE_TOOLS=ON
        -DAMReX_PROFPARSER=OFF
        -DAMReX_SENSEI=OFF
        -DAMReX_SUNDIALS=OFF
        -DAMReX_TINY_PROFILE=OFF
        -DUSE_XSDK_DEFAULTS=OFF
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
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
