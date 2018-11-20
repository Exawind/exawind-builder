#!/bin/bash

__EXAWIND_CORESRC_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
__EXAWIND_CORE_DIR=${__EXAWIND_CORE_DIR:-$(dirname ${__EXAWIND_CORESRC_DIR})}

# Array holding exact module/spack descriptor for a dependency
declare -A EXAWIND_MODMAP

export EXAWIND_COMPILER_DEFAULT=gcc

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

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        if [ -z ${!root_dir_var} ] ; then
            module load ${EXAWIND_MODMAP[$dep]:-$dep}
        fi
    done
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
