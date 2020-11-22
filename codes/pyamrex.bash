#!/usr/bin/env bash

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    _skbuild
    pyAMReX.egg-info
)

exawind_proj_env ()
{
    local opt_packages=(
        hypre
    )

    echo "==> Loading dependencies for pyAMReX ..."
    exawind_load_deps amrex

    for pkg in ${opt_packages[@]} ; do
        local pkg_flag="ENABLE_${pkg^^}"
        if [ "${!pkg_flag:-ON}" = "ON" ] ; then
            exawind_load_deps $pkg
        fi
    done

    echo "==> Initializing python environment for pyAMReX"
    exawind_py_env
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
        -DAMReX_ROOT=${AMREX_ROOT_DIR}
        -DHYPRE_ROOT=${HYPRE_ROOT_DIR}
        "$@"
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
