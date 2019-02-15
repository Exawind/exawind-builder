#!/bin/bash

__EXAWIND_CORESRC_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
__EXAWIND_CORE_DIR=${__EXAWIND_CORE_DIR:-$(dirname ${__EXAWIND_CORESRC_DIR})}

# Array holding exact module/spack descriptor for a dependency
declare -A EXAWIND_MODMAP

export EXAWIND_COMPILER_DEFAULT=gcc
export EXAWIND_DEP_LOADER=spack

exawind_env ()
{
    local srcdir=${__EXAWIND_CORE_DIR}
    if [ -z "$EXAWIND_SYSTEM" ] ; then
        echo "EXAWIND_SYSTEM variable has not been defined"
        exit 1
    fi

    local compiler=${EXAWIND_COMPILER:-${EXAWIND_COMPILER_DEFAULT}}
    exawind_env_${compiler}
}

exawind_default_install_dir ()
{
    local project_name=$1
    local root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"
    local install_path=${EXAWIND_INSTALL_DIR}/${project_name}

    echo "==> ${project_name}: Cannot find standard module; attempting to detect local install"
    echo "==> ${project_name}: Set ${root_dir_var} to provide the exact location"
    if [ -d ${install_path} ] ; then
       eval "export $root_dir_var=${install_path}"
    else
        echo "==> WARNING! Cannot load dependency: ${project_name}"
    fi
}

exawind_load_modules ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${!root_dir_var} ] ; then
            module load ${depname} || exawind_default_install_dir $dep
        fi
        echo "==> ${depname} = ${!root_dir_var}"
    done
}

exawind_load_spack ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${!root_dir_var} ] ; then
            ${SPACK_EXE} module tcl find $depname %${SPACK_COMPILER} &>/dev/null &&
            {
                module load $(${SPACK_EXE} module tcl find $depname %${SPACK_COMPILER})
                eval "export $root_dir_var=$(${SPACK_EXE} location -i $depname %${SPACK_COMPILER})"
            } || exawind_default_install_dir $dep
        fi
        echo "==> ${depname} = ${!root_dir_var}"
    done
}

exawind_load_deps ()
{
    local loader_type=${EXAWIND_DEP_LOADER:-spack}

    case ${loader_type} in
        spack)
            exawind_load_spack $@
            ;;

        module)
            exawind_load_modules $@
            ;;
        *)
            echo "==> ERROR! Cannot determine how to load dependencies"
            exit 1
            ;;
    esac
}

exawind_load_user_configs ()
{
    local cfgname=${EXAWIND_CFGFILE:-exawind-config}
    local global_cfg=${EXAWIND_CONFIG:-${EXAWIND_PROJECT_DIR}/${EXAWIND_CFGFILE}.sh}
    local cfgfiles=(
        ${HOME}/.${cfgname}
        ${global_cfg}
        $(pwd)/${cfgname}.sh
    )

    for cfg in ${cfgfiles[@]}; do
        if [ -f ${cfg} ] ; then
            echo "==> Loading options from ${cfg}"
            source ${cfg}
        fi
    done
}

exawind_purge_env ()
{
    # Remove if we set it up
    if [ ! -z "${SPACK_EXE}" ] ; then
        echo "==> Purging spack variables"
        module unuse ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)
        unset SPACK_ROOT
        unset SPACK_EXE
        unset SPACK_COMPILER
    fi

    # Unset any project specific variables
    echo "==> Purging project specific variables"
    for prj in $(ls ${__EXAWIND_CORE_DIR}/codes/*.bash) ; do
        local prjname=$(basename ${prj} .bash)
        local prjvar="$(echo ${prjname} | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"
        unset ${prjvar}_ROOT_DIR
        unset ${prjvar}_INSTALL_PREFIX
        unset ${prjvar}_SOURCE_DIR
    done

    echo "==> Purging exawind-builder variables"
    for exvar in $(compgen -v EXAWIND_) ; do
        unset ${exvar}
    done

    # Unset all private EXAWIND variables
    for exvar in $(compgen -v __EXAWIND_) ; do
        unset ${exvar}
    done

    echo "==> Purging exawind function definitions"
    for exfunc in $(compgen -A function exawind_) ; do
        unset ${exfunc}
    done
}
