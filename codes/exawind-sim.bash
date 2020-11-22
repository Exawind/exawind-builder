#!/usr/bin/env bash

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    _skbuild
    exawind_sim.egg-info
)

exawind_proj_env ()
{
    local opt_packages=(
        hypre
        openfast
    )

    echo "==> Loading dependencies for exawind-sim ..."
    exawind_load_deps netcdf-c yaml-cpp trilinos amrex tioga nalu-wind amr-wind

    for pkg in ${opt_packages[@]} ; do
        local pkg_flag="ENABLE_${pkg^^}"
        if [ "${!pkg_flag:-ON}" = "ON" ] ; then
            exawind_load_deps $pkg
        fi
    done

    echo "==> Initializing python environment for exawind-sim"
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
