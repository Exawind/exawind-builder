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
    local num_tasks=${EXAWIND_NUM_JOBS:-$EXAWIND_NUM_JOBS_DEFAULT}
    local pycmd=(
        python3 setup.py build_ext
        --skip-generator-test
        -G Ninja
        -j ${num_tasks}
        --inplace --
        -DCMAKE_PREFIX_PATH="${TRILINOS_ROOT_DIR}" "$@"
    )

    echo "${pycmd[@]}" > pybuild_output.log
    eval "${pycmd[@]}" |& tee -a pybuild_output.log
}

exawind_py_install ()
{
    pip3 install -e .
}

exawind_default_cmd ()
{
    exawind_py_build "$@" && exawind_py_install
}
