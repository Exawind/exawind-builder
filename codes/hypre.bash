#!bin/bash

exawind_proj_env ()
{
    echo "HYPRE: No additional dependencies"
}

exawind_cmake ()
{
    # Not exactly CMake, but we use this function anyway. Must be executed from
    # `hypre/src` directory

    local extra_args="$@"
    local install_dir=""
    local enable_openmp=${HYPRE_OPENMP:-NO}
    local openmp_args=" --without-openmp "

    if [ -n "$HYPRE_INSTALL_PREFIX" ] ; then
        install_dir="$HYPRE_INSTALL_PREFIX"
    else
        install_dir="$(cd .. && pwd)/install"
    fi

    if [ "${enable_openmp}" = "YES" ] ; then
        echo "-- HYPRE: Enabling OpenMP"
        openmp_args=" --with-openmp "
    else
        echo "-- HYPRE: Disabling OpenMP"
    fi

    ./configure --prefix=${HYPRE_INSTALL_PREFIX} --without-superlu --enable-bigint ${openmp_args} ${extra_args}
}
