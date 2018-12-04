#!/bin/bash

# Install Ninja build system for faster builds

exw_get_ninja ()
{
    local srcdir=${EXAWIND_PROJECT_DIR}/source
    cd ${srcdir}

    if [ ! -d ninja ] ; then
        echo "==> Fetching ninja: ${srcdir}/ninja"
        git clone https://github.com/Kitware/ninja.git
    fi

    if [ ! -f ninja/ninja ] ; then
        echo "==> Attempting to build ninja"
        cd ${srcdir}/ninja/
        ./configure.py --bootstrap
    fi
}

exw_set_ninja ()
{
    local cfgfile=${EXAWIND_PROJECT_DIR}/exawind-config.sh

    echo "==> Setting ninja as the default build system in ${cfgfile}"
    cat <<EOF >> ${cfgfile}

# Set Ninja as the build system
EXAWIND_MAKE_TYPE=ninja
export PATH=${EXAWIND_PROJECT_DIR}/source/ninja:\${PATH}

EOF
}

exw_main ()
{
    local utils_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
    local core_dir=$(dirname $utils_dir)
    local prj_dir=$(dirname $core_dir)
    export EXAWIND_PROJECT_DIR=${EXAWIND_PROJECT_DIR:-${prj_dir}}

    exw_get_ninja
    exw_set_ninja
}

exw_main "$@"
