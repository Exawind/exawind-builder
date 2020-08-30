#!bin/bash

exawind_proj_env ()
{
    echo "==> HYPRE: No additional dependencies"
}

exawind_hypre_fix_gpu ()
{
    unset OMPI_CXX
    unset EXAWIND_CUDA_WRAPPER
    unset NVCC_WRAPPER_DEFAULT_COMPILER

    export CUDA_HOME=${CUDA_HOME:-$(dirname $(dirname $(which nvcc)))}
    export CXX=$(which g++)
}

exawind_cmake_base ()
{
    # Not exactly CMake, but we use this function anyway. Must be executed from
    # `hypre/src` directory

    local extra_args_inp=( "$@" )
    local install_dir=""
    local enable_openmp=${ENABLE_OPENMP:-OFF}
    local enable_bigint=${ENABLE_BIGINT:-ON}
    local enable_cuda=${ENABLE_CUDA:-OFF}
    local enable_uvm=${HYPRE_ENABLE_UVM:-ON}
    local openmp_args=" --without-openmp "
    local bigint_args=""
    local cuda_args=" --without-cuda "
    local uvm_args=""
    local extra_args=""

    # HYPRE configure cannot handle Ninja builds, so disable any CMake
    # directives that got added
    if [[ $extra_args_inp[0] = -G* ]] ; then
        extra_args=${extra_args_inp[@]:1}
    else
        extra_args=${extra_args_inp}
    fi

    if [ -n "$HYPRE_INSTALL_PREFIX" ] ; then
        install_dir="$HYPRE_INSTALL_PREFIX"
    else
        install_dir="$(cd .. && pwd)/install"
    fi

    if [ "${enable_openmp}" = "ON" ] ; then
        echo "==> HYPRE: Enabling OpenMP"
        openmp_args=" --with-openmp "
    else
        echo "==> HYPRE: Disabling OpenMP"
    fi
    if [ "${enable_cuda}" = "ON" ] ; then
        echo "==> HYPRE: Enabling CUDA"
        cuda_args=" --with-cuda "
        export HYPRE_CUDA_SM=${EXAWIND_CUDA_SM:-60}
        exawind_hypre_fix_gpu

        if [ "${enable_uvm}" = "ON" ] ; then
            uvm_args=" --enable-unified-memory "
        else
            uvm_args=" --disable-unified-memory "
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

    local config_cmd=(
        ./configure
        --prefix=${HYPRE_INSTALL_PREFIX}
        --without-superlu
        ${bigint_args}
        ${openmp_args}
        ${cuda_args}
        ${uvm_args}
        ${extra_args[@]}
    )

    echo "${config_cmd[@]}"
    eval "${config_cmd[@]}"
    echo "==> Executing make clean to force full recompile"
    command make clean > /dev/null
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

    command make ${extra_args} 2>&1 | tee make_output.log
}
