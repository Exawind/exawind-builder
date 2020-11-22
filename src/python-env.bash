#!/bin/bash

__EXAWIND_CORESRC_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
__EXAWIND_CORE_DIR=${__EXAWIND_CORE_DIR:-$(dirname ${__EXAWIND_CORESRC_DIR})}

export EXAWIND_PYENV_TYPE_DEFAULT=conda
export EXAWIND_CONDA_ENV_DEFAULT=exawind
export EXAWIND_CONDA_ENV_SPEC_DEFAULT=${__EXAWIND_CORE_DIR}/etc/python/conda/conda-env-default.yml
export EXAWIND_PYVENV_DEFAULT=exawind
export EXAWIND_PYVENV_SPEC_DEFAULT=${__EXAWIND_CORE_DIR}/etc/python/venv/exawind-pip-requirements.txt

exawind_py_env ()
{
    export EXAWIND_PYENV_TYPE=${EXAWIND_PYENV_TYPE:-${EXAWIND_PYENV_TYPE_DEFAULT}}

    case ${EXAWIND_PYENV_TYPE} in
        "conda")
            exawind_py_conda_env
            ;;

        "venv")
            exawind_pyvenv_env
            ;;

        *)
            echo "ERROR: Only conda and virtual environments supported at this time"
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

exawind_pyvenv_env ()
{
    export EXAWIND_PYVENV=${EXAWIND_PYVENV:-${EXAWIND_PYVENV_DEFAULT}}
    export EXAWIND_PYVENV_ROOT=${EXAWIND_PYVENV_ROOT:-${EXAWIND_PROJECT_DIR}/.virtualenvs}

    _exw_pyvenv_init
    source ${EXAWIND_PYVENV_ROOT}/${EXAWIND_PYVENV}/bin/activate
    echo "==> Activated virtual python environment = ${EXAWIND_PYVENV}"
}

exawind_pyvenv_create ()
{
    export EXAWIND_PYVENV=${EXAWIND_PYVENV:-${EXAWIND_PYVENV_DEFAULT}}
    export EXAWIND_PYVENV_ROOT=${EXAWIND_PYVENV_ROOT:-${EXAWIND_PROJECT_DIR}/.virtualenvs}
    export EXAWIND_PYVENV_SPEC=${EXAWIND_PYVENV_SPEC:-${EXAWIND_PYVENV_SPEC_DEFAULT}}

    exawind_load_deps hdf5 netcdf-c parallel-netcdf
    export HDF5_DIR=${HDF5_ROOT_DIR}

    _exw_pyvenv_init

    echo "==> Creating python virtual environment = ${EXAWIND_PYVENV}"
    echo "==> Python requirements file = ${EXAWIND_PYVENV_SPEC}"
    echo "==> Using python executable: $(which python3)"
    python3 -m venv --system-site-packages ${EXAWIND_PYVENV_ROOT}/${EXAWIND_PYVENV}
    source ${EXAWIND_PYVENV_ROOT}/${EXAWIND_PYVENV}/bin/activate
    pip3 install -r ${EXAWIND_PYVENV_SPEC}
}

_exw_pyvenv_init ()
{
    echo "==> Using default system python"
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

