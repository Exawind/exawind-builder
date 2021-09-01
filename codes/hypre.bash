#!bin/bash

export EXAWIND_GPU_KOKKOS_ENV=OFF

exawind_proj_env ()
{
    local opt_packages=(
        umpire
    )

    echo "==> Loading optional dependencies for Hypre ..."

    for pkg in ${opt_packages[@]} ; do
        local pkg_flag="ENABLE_${pkg^^}"
        if [ "${!pkg_flag:-OFF}" = "ON" ] ; then
            exawind_load_deps $pkg
        fi
    done

}

exawind_hypre_fix_gpu ()
{
    if [ "${EXAWIND_GPU_KOKKOS_ENV:-OFF}" = "ON" ] ; then
      echo "ERROR: Cannot build hypre with Kokkos nvcc_wrapper"
      exit 1
    fi
    unset EXAWIND_CUDA_WRAPPER
    unset NVCC_WRAPPER_DEFAULT_COMPILER

    export CUDA_HOME=${CUDA_HOME:-$(dirname $(dirname $(which nvcc)))}
    export CXXFLAGS=${CXXFLAGS:-"-O2"}
    export CFLAGS=${CXXFLAGS:-"-O2"}
}

exawind_cmake_base ()
{
    # Not exactly CMake, but we use this function anyway. Must be executed from
    # `hypre/src` directory

    local install_dir=""
    local enable_openmp=${ENABLE_OPENMP:-OFF}
    local enable_bigint=${ENABLE_BIGINT:-ON}
    local shared_args=" --disable-shared "
    local openmp_args=" --without-openmp "
    local bigint_args=""
    local cuda_args=" --without-cuda "
    local uvm_args=""
    local umpire_args=""
    local extra_args=( "$@" )

    if [ -n "$HYPRE_INSTALL_PREFIX" ] ; then
        install_dir="$HYPRE_INSTALL_PREFIX"
    else
        install_dir="$(cd .. && pwd)/install"
    fi

    if [ "${BUILD_SHARED_LIBS:-OFF}" = "ON" ] ; then
        echo "==> HYPRE: Enabling shared library build"
        shared_args=" --enable-shared "
    else
        shared_args=" --disable-shared "
    fi

    if [ "${enable_openmp}" = "ON" ] ; then
        echo "==> HYPRE: Enabling OpenMP"
        openmp_args=" --with-openmp "
    else
        echo "==> HYPRE: Disabling OpenMP"
    fi
    if [ "${ENABLE_CUDA:-OFF}" = "ON" ] ; then
        echo "==> HYPRE: Enabling CUDA"
        cuda_args=" --with-cuda "
        export HYPRE_CUDA_SM=${HYPRE_CUDA_SM:-${EXAWIND_CUDA_SM:-70}}
        exawind_hypre_fix_gpu

        if [ "${HYPRE_ENABLE_UVM:-ON}" = "ON" ] ; then
            echo "==> HYPRE: Enabling CUDA unified memory"
            cuda_args="${cuda_args} --enable-unified-memory "
        else
            echo "==> HYPRE: Disabling CUDA unified memory"
            cuda_args="${cuda_args} --disable-unified-memory "
        fi

        if [ "${HYPRE_ENABLE_CURAND:-ON}" = "ON" ] ; then
            echo "==> HYPRE: Enabling CUDA curand"
            cuda_args="${cuda_args} --enable-curand "
        else
            echo "==> HYPRE: Disabling CUDA curand"
            cuda_args="${cuda_args} --disable-curand "
        fi

        if [ "${HYPRE_ENABLE_CUSPARSE:-ON}" = "ON" ] ; then
            echo "==> HYPRE: Enabling CUDA cusparse"
            cuda_args="${cuda_args} --enable-cusparse "
        else
            echo "==> HYPRE: Disabling CUDA cusparse"
            cuda_args="${cuda_args} --disable-cusparse "
        fi

        if [ "${HYPRE_ENABLE_CUBLAS:-OFF}" = "ON" ] ; then
            echo "==> HYPRE: Enabling CUDA cublas"
            cuda_args="${cuda_args} --enable-cublas "
        else
            echo "==> HYPRE: Disabling CUDA cublas"
            cuda_args="${cuda_args} --disable-cublas "
        fi

        if [ "${HYPRE_ENABLE_GPU_AWARE_MPI:-OFF}" = "ON" ] ; then
            echo "==> HYPRE: Enabling GPU Aware MPI"
            cuda_args="${cuda_args} --enable-gpu-aware-mpi "
        else
            echo "==> HYPRE: Disabling GPU Aware MPI"
        fi

        if [ "${HYPRE_ENABLE_GPU_PROFILING:-OFF}" = "ON" ] ; then
            echo "==> HYPRE: Enabling GPU Profiling"
            cuda_args="${cuda_args}  --enable-gpu-profiling "
        else
            echo "==> HYPRE: Disabling GPU Profiling"
        fi

        # Disable BIGINT as it doesn't work with CUDA
        enable_bigint=OFF
    else
        echo "==> HYPRE: Disabling CUDA"
    fi

    if [ "${enable_bigint}" = "ON" ] ; then
        echo "==> HYPRE: Enabling big Integer support"
        bigint_args=" --enable-bigint "
    else
        echo "==> HYPRE: Disabling big Integer support"
        bigint_args=" --disable-bigint "
    fi

    if [ "${ENABLE_UMPIRE:-OFF}" = "ON" ] ; then
        echo "==> HYPRE: Enabling Umpire"
        umpire_args=" --with-umpire "
        umpire_args=" ${umpire_args} --with-umpire-include=$UMPIRE_ROOT_DIR/include/"
        umpire_args=" ${umpire_args} --with-umpire-lib-dirs=$UMPIRE_ROOT_DIR/lib/"
        umpire_args=" ${umpire_args} --with-umpire-libs=umpire"
    fi

    local config_cmd=(
        ./configure
        CXX=${MPICXX}
        CC=${MPICC}
        FC=${MPIFC}
        --prefix=${install_dir}
        --without-superlu
        ${bigint_args}
        ${openmp_args}
        ${cuda_args}
        ${shared_args}
        ${umpire_args}
        ${extra_args[@]}
    )

    echo "${config_cmd[@]}"
    eval "${config_cmd[@]}"
    echo "==> Executing make clean to force full recompile"
    command make clean > /dev/null
}

exawind_cmake ()
{
    if [ "$(uname)" = "Darwin" -a "$(type -t exawind_cmake_osx)" = "function" ] ; then
        exawind_cmake_osx "$@"
    elif [ "$(type -t exawind_cmake_${EXAWIND_SYSTEM})" = "function" ] ; then
        exawind_cmake_${EXAWIND_SYSTEM} "$@"
    else
        exawind_cmake_base "$@"
    fi
}

exawind_make ()
{
    local num_tasks=${EXAWIND_NUM_JOBS:-$EXAWIND_NUM_JOBS_DEFAULT}

    if [ "$#" == "0" ] ; then
        extra_args="-j ${num_tasks}"
    else
        extra_args="$@"
    fi

    if [ "${ENABLE_CUDA:-OFF}" = "ON" ] ; then
       exawind_hypre_fix_gpu
    fi

    command make ${extra_args} |& tee make_output.log
}
