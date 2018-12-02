#!/bin/bash

# Install Ninja build system for faster builds

exw_get_ninja ()
{
    local srcdir=${EXAWIND_PROJECT_DIR}/source
    cd ${srcdir}

    if [ ! -d ninja ] ; then
        git clone https://github.com/Kitware/ninja.git
    fi

    if [ ! -f ninja/ninja ] ; then
        cd ${srcdir}/ninja/
        ./configure.py --bootstrap
    fi
}

exw_set_ninja ()
{
    local cfgfile=${EXAWIND_PROJECT_DIR}/exawind-config.sh

    cat <<EOF >> ${cfgfile}

# Set Ninja as the build system
EXAWIND_MAKE_TYPE=ninja
export PATH=${EXAWIND_PROJECT_DIR}/source/ninja:\${PATH}

EOF
}

exw_main ()
{
    export EXAWIND_PROJECT_DIR=${EXAWIND_PROJECT_DIR:-${HOME}/exawind}

    exw_get_ninja
    exw_set_ninja
}

exw_main "$@"
