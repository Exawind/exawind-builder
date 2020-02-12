#!/usr/bin/env bash

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    _skbuild
    pySTK.egg-info
)

exawind_proj_env ()
{
    echo "==> Initializing python environment for pySTK"
    exawind_py_env

    echo "==> Loading dependencies for pySTK ... "
    exawind_load_deps trilinos
}

exawind_cmake_base ()
{
    echo "WARN: Use py_build instead"
    exawind_py_build "$@"
}

exawind_make ()
{
    echo "WARN: Use py_build instead"
    exawind_py_build "$@"
}

exawind_py_build ()
{
    python setup.py build_ext --inplace -- -DCMAKE_PREFIX_PATH=${TRILINOS_ROOT_DIR} "$@"
}

exawind_py_install ()
{
    pip install -e .
}

exawind_default_cmd ()
{
    exawind_py_build "$@" && exawind_py_install
}
