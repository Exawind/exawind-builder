#!bin/bash

exawind_proj_env ()
{
    echo "==> HYPRE: No additional dependencies"
}

exawind_cmake_base ()
{
    # Not exactly CMake, but we use this function anyway. Must be executed from
    # `hypre/src` directory

    local extra_args="$@"
    local install_dir=""
    local enable_openmp=${ENABLE_OPENMP:-NO}
    local enable_bigint=${ENABLE_BIGINT:-YES}
    local openmp_args=" --without-openmp "
    local bigint_args=" --enable-bigint "

    if [ -n "$HYPRE_INSTALL_PREFIX" ] ; then
        install_dir="$HYPRE_INSTALL_PREFIX"
    else
        install_dir="$(cd .. && pwd)/install"
    fi

    if [ "${enable_openmp}" = "YES" ] ; then
        echo "==> HYPRE: Enabling OpenMP"
        openmp_args=" --with-openmp "
    else
        echo "==> HYPRE: Disabling OpenMP"
    fi

    if [ "${enable_bigint}" = "YES" ] ; then
        echo "==> HYPRE: Enabling big Integer support"
    else
        echo "==> HYPRE: Disabling big Integer support"
        bigint_args=" --disable-bigint "
    fi

    ./configure --prefix=${HYPRE_INSTALL_PREFIX} --without-superlu ${bigint_args} ${openmp_args} ${extra_args}
}
