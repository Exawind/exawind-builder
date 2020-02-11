#!/bin/bash

__EXAWIND_CORESRC_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
__EXAWIND_CORE_DIR=${__EXAWIND_CORE_DIR:-$(dirname ${__EXAWIND_CORESRC_DIR})}

# Array holding exact module/spack descriptor for a dependency
declare -A EXAWIND_MODMAP

# Array holding extra modules to be loaded based on user configuration
declare -a EXAWIND_EXTRA_USER_MODULES

export EXAWIND_COMPILER_DEFAULT=gcc
export EXAWIND_DEP_LOADER=spack
export EXAWIND_CUDA_WRAPPER_DEFAULT=${__EXAWIND_CORE_DIR}/utils/nvcc_wrapper

exawind_env ()
{
    local srcdir=${__EXAWIND_CORE_DIR}
    if [ -z "$EXAWIND_SYSTEM" ] ; then
        echo "EXAWIND_SYSTEM variable has not been defined"
        exit 1
    fi

    local compiler=${EXAWIND_COMPILER:-${EXAWIND_COMPILER_DEFAULT}}
    exawind_env_${compiler}

    # Load any additional modules defined by the user
    if [ ${#EXAWIND_EXTRA_USER_MODULES[@]} -gt 0 ] ; then
        echo "==> Loading additional user modules: "
        exawind_load_deps ${EXAWIND_EXTRA_USER_MODULES}
    fi

    # Allow user to customize the environment further
    exawind_env_user_actions
}

exawind_env_user_actions ()
{
    echo "==> No user environment actions defined"
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

        eval "export root_dir_value=\"\${$root_dir_var}\""
        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${root_dir_value} ] ; then
            echo "==> spack: locating $depname%${SPACK_COMPILER}"
            ${SPACK_EXE} module tcl find $depname %${SPACK_COMPILER} &>/dev/null &&
            {
                module load $(${SPACK_EXE} module tcl find $depname %${SPACK_COMPILER})
                eval "export $root_dir_var=$(${SPACK_EXE} location -i $depname %${SPACK_COMPILER})"
                eval "export root_dir_value=\"\${$root_dir_var}\""
            } || exawind_default_install_dir $dep
        fi
        echo "==> ${depname} = ${root_dir_value}"
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
    local cfgfiles=(
        ${HOME}/.${cfgname}
        ${HOME}/.${cfgname}-${EXAWIND_COMPILER}
        ${EXAWIND_PROJECT_DIR}/${EXAWIND_CFGFILE}.sh
        ${EXAWIND_PROJECT_DIR}/${EXAWIND_CFGFILE}-${EXAWIND_COMPILER}.sh
        ${EXAWIND_CONFIG}
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
        unset -v SPACK_ROOT
        unset -v SPACK_EXE
        unset -v SPACK_COMPILER
    fi

    # Unset any project specific variables
    echo "==> Purging project specific variables"
    for prj in $(ls ${__EXAWIND_CORE_DIR}/codes/*.bash) ; do
        local prjname=$(basename ${prj} .bash)
        local prjvar="$(echo ${prjname} | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')"
        unset -v ${prjvar}_ROOT_DIR
        unset -v ${prjvar}_INSTALL_PREFIX
        unset -v ${prjvar}_SOURCE_DIR
    done

    echo "==> Purging exawind-builder variables"
    for exvar in $(compgen -v EXAWIND_) ; do
        unset -v ${exvar}
    done

    # Unset all private EXAWIND variables
    for exvar in $(compgen -v __EXAWIND_) ; do
        unset -v ${exvar}
    done

    echo "==> Purging exawind function definitions"
    for exfunc in $(compgen -A function exawind_) ; do
        unset -f ${exfunc}
    done
}
