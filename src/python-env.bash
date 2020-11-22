#!/bin/bash

__EXAWIND_CORESRC_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
__EXAWIND_CORE_DIR=${__EXAWIND_CORE_DIR:-$(dirname ${__EXAWIND_CORESRC_DIR})}

export EXAWIND_PYENV_TYPE_DEFAULT=conda
export EXAWIND_CONDA_ENV_DEFAULT=exawind
export EXAWIND_CONDA_ENV_SPEC_DEFAULT=${__EXAWIND_CORE_DIR}/etc/python/conda/conda-env-default.yml

exawind_py_env ()
{
    export EXAWIND_PYENV_TYPE=${EXAWIND_PYENV_TYPE:-${EXAWIND_PYENV_TYPE_DEFAULT}}

    case ${EXAWIND_PYENV_TYPE} in
        "conda")
            exawind_py_conda_env
            ;;

        *)
            echo "ERROR: Only conda environments supported at this time"
            exit 1
            ;;
    esac
}

exawind_py_conda_env ()
{
    export EXAWIND_CONDA_ENV=${EXAWIND_CONDA_ENV:-${EXAWIND_CONDA_ENV_DEFAULT}}

    _exw_py_conda_init
    conda activate ${EXAWIND_CONDA_ENV}

    echo "==> Activated conda python environment = ${EXAWIND_CONDA_ENV}"
}

exawind_py_conda_env_create ()
{
    export EXAWIND_CONDA_ENV_SPEC=${EXAWIND_CONDA_ENV_SPEC:-${EXAWIND_CONDA_ENV_SPEC_DEFAULT}}
    export EXAWIND_CONDA_ENV=${EXAWIND_CONDA_ENV:-${EXAWIND_CONDA_ENV_DEFAULT}}

    _exw_py_conda_init

    # Ensure that we have defined the right compilers for building mpi4py, pystk etc
    export CXX=${CXX:-$(which mpic++)}
    export CC=${CC:-$(which mpicc)}
    export FC=${FC:-$(which mpifort)}

    exawind_load_deps hdf5 netcdf parallel-netcdf
    export HDF5_DIR=${HDF5_ROOT_DIR}

    echo "==> Creating conda environment = ${EXAWIND_CONDA_ENV}"
    echo "==> Environment definition file = ${EXAWIND_CONDA_ENV_SPEC}"
    conda env create -n ${EXAWIND_CONDA_ENV} -f ${EXAWIND_CONDA_ENV_SPEC}
}

_exw_py_conda_get_root ()
{
    if [ ! -n ${CONDA_ROOT_DIR} ] ; then
        if [ -z "${CONDA_EXE}" ] ; then
            export CONDA_ROOT_DIR=${HOME}/anaconda
        else
            export CONDA_ROOT_DIR=$(dirname $(dirname ${CONDA_EXE}))
        fi
    fi

    if [ ! -d ${CONDA_ROOT_DIR} ] ; then
        echo "ERROR: Cannot determine conda root directory"
        exit 1
    fi

    echo "==> Using conda installation at ${CONDA_ROOT_DIR}"
}

_exw_py_conda_init ()
{
    # Ensure CONDA_ROOT_DIR is active
    _exw_py_conda_get_root
    local shell_name="bash"
    if [ -n ${ZSH_NAME} ] ; then
        shell_name="zsh"
    fi

    eval "$(${CONDA_ROOT_DIR}/bin/conda shell.${shell_name} hook)"
    echo "==> Initialized conda in ${CONDA_ROOT_DIR}"
}

_exw_py_conda_deactivate_all ()
{
    while [ -n ${CONDA_PREFIX} ] ; do
        conda deactivate
    done
}

